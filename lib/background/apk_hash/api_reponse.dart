
enum HashVerdict {
  SCAN_REQUIRED(-1),
  NEED_UPLOAD(0),
  WHITE_LIST(1),
  SAFE(2),
  MALWARE(3);

  const HashVerdict(this.value);
  final int value;
}