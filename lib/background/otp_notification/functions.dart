import 'package:cysecurity/database/otp_scan/model/model.dart';
import 'package:cysecurity/database/otp_scan/provider.dart';

class OtpFunctions {

  OtpScanProvider otp = OtpScanProvider();

  Future addOtp(OtpScanModel data) async {
    await otp.initializationDone;
    otp.addNotifiedOtp(data);
  }
}