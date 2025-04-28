{
  fetchFromGitHub,
  applyPatches,
  patches ? [ ],
}:
let
  version = "4.3.7";
in
(applyPatches {
  src = fetchFromGitHub {
    owner = "glitch-soc";
    repo = "mastodon";
    rev = "v${version}";
    hash = "sha256-KmeWBMuyJ/ZdZnFXAlpvgXV+J8IZrcaTXvvui4l6mjY=";
  };
  patches = patches ++ [ ];
})
// {
  inherit version;
  yarnHash = "sha256-e5c04M6XplAgaVyldU5HmYMYtY3MAWs+a8Z/BGSyGBg=";
}
