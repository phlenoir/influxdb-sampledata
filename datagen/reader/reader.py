import logging

class ReaderAbstract(object):
    """
    Abstract consumer
    """

    def __init__(self):
        """
        Initialize reader
        """
        # Initialized on read
        self.consumer = None

    def read(self):
        """
        Read. Reconnect on error.
        """
        try:
            self._connect()
            for msg in self._handle_read():
                yield msg
        finally:
            logging.info("Performing cleanup before stopping.")
            self._shutdown()

    def _connect(self):
        """
        Overwrite in child classes
        """
        raise NotImplementedError

    def _shutdown(self):
        """
        Cleanup tasks.
        Can be overwritten by specific readers if required.
        """
        if self.consumer:
            self.consumer.close()

    def _handle_read(self):
        """
        Read messages.
        Library-specific internal message handling.
        Needs to be implemented by every reader
        """
        raise NotImplementedError
