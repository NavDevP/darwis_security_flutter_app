enum LinkVerdict {
  SCAN_REQUIRED(-1),
  WHITE_LIST(1),
  SPAM(2);

  const LinkVerdict(this.value);

  final int value;
}