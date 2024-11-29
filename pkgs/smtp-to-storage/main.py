#!/usr/bin/env python
import os
import logging
import asyncio
from aiosmtpd.controller import Controller

class CustomSMTPHandler:
    def __init__(self):
        self.save_dir = "/var/lib/smtp-to-storage"

    async def handle_DATA(self, server, session, envelope):
        print('Message from %s' % envelope.mail_from)
        for part in envelope.iter_attachments():
            filename = part.get_filename()
            if filename:
                filepath = os.path.join(self.save_dir, filename)
                with open(filepath, 'wb') as f:
                    f.write(part.get_payload(decode=True))

async def amain(loop):
    cont = Controller(CustomSMTPHandler(), hostname='localhost', port=9212)
    cont.start()

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    loop.create_task(amain(loop=loop))  # type: ignore[unused-awaitable]
    try:
        loop.run_forever()
    except KeyboardInterrupt:
        print("User abort indicated")
