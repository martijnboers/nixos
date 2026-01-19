{
  lib,
  stdenv,
  fetchFromGitHub,
  bundlerEnv,
  ruby,
  postgresql,
  pkg-config, 
  nodejs,
  makeWrapper,
  curl,
  git,
  libyaml,
  vips, 
}:

# curl -s -O https://raw.githubusercontent.com/we-promise/sure/main/Gemfile
# sed -i '/^ruby/d' Gemfile
# sed -i '/tzinfo-data/d' Gemfile
# sed -i '/platforms:.*windows/d' Gemfile
# nix-shell -p bundler --run "
#     rm -f Gemfile.lock
#     bundle config set --local force_ruby_platform true
#     bundle lock --add-platform x86_64-linux
# "
# nix-shell -p bundix --run "bundix -l"

let
  pname = "sure";
  version = "main";

  src = fetchFromGitHub {
    owner = "we-promise";
    repo = "sure";
    rev = "main";
    hash = "sha256-0/C+zfdTGDV6Z88ZaksoDDSv5WxSWO1Ys99fJ6zARCE=";
  };

  myRailsEnv = bundlerEnv {
    name = "${pname}-env";
    inherit ruby;

    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;

    gemConfig = {
      pg = attrs: {
        buildInputs = [ postgresql ];
      };
      psych = attrs: {
        buildInputs = [ libyaml ];
      };
      ruby-vips = attrs: {
        buildInputs = [
          vips
          pkg-config
        ];
      };
    };
  };

in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    myRailsEnv
    ruby
    postgresql
    nodejs
    git
    vips
    libyaml
  ];

  env = {
    RAILS_ENV = "production";
    BUNDLE_WITHOUT = "development test";
    SECRET_KEY_BASE_DUMMY = "1";
  };

  postPatch = ''
    cp ${./Gemfile} Gemfile
    cp ${./Gemfile.lock} Gemfile.lock
  '';

  buildPhase = ''
    runHook preBuild
    export HOME=$(mktemp -d)
    ln -sf ${myRailsEnv}/lib/ruby/gems .bundle

    ${myRailsEnv}/bin/rails assets:precompile || echo "Asset compilation warning"

    rm -rf tmp/cache
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r . $out
    rm -rf $out/tmp/* $out/log/*

    mkdir -p $out/bin
    makeWrapper ${myRailsEnv}/bin/rails $out/bin/sure-server \
      --chdir $out \
      --set BUNDLE_GEMFILE $out/Gemfile \
      --set RAILS_ENV production \
      --set RAILS_LOG_TO_STDOUT true \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
          postgresql
          curl
          git
          vips
        ]
      }
    runHook postInstall
  '';

  meta = with lib; {
    description = "Sure Rails App";
    homepage = "https://github.com/we-promise/sure";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
