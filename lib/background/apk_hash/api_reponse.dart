abstract class Verdict {
  // properties
  String malware;
  int verdict;

  // constructor
  Verdict(this.malware, this.verdict);

  // abstract method
  void run();
}

// mixin CanRun is only used by class that extends Animal
mixin VerdictResponse on Verdict {
  // implementation of abstract method
  @override
  void run() => print('$malware is verdict $verdict');
}

class ApkHashResponse extends Verdict with VerdictResponse{

  ApkHashResponse(String malware, int verdict): super(malware, verdict);

}
