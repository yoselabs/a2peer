"""a2peer: consult other agents as advisors from one agent session, over MCP."""

import argparse
import sys
from collections.abc import Sequence


def main(argv: Sequence[str] | None = None) -> None:
    """Entry point for the `a2peer` command. The MCP server is not built yet."""
    parser = argparse.ArgumentParser(prog="a2peer", description=__doc__)
    parser.parse_args(argv)
    sys.stdout.write("a2peer: not built yet; see docs/design.md\n")
