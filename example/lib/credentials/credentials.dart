import 'package:envied/envied.dart';

/// This file contains the credentials classes for the sample app.
/// You can use the default credentials provided by the Flutter Sample community.
/// Or you can create your own community and use the credentials from there.
/// To use your own community, create a file named [.env.dev] in the root directory
/// for beta credentials and [.env.prod] for production credentials.
/// Then run the following command to generate the credentials classes:
///   flutter pub run build_runner build
/// This will automatically generate the file [credentials.g.dart] in the same directory.

part 'credentials.g.dart';

///These are BETA sample community credentials
@Envied(name: 'CredsDev', path: '.env.dev')
abstract class CredsDev {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _CredsDev.apiKey;
  @EnviedField(varName: 'BOT_ID', obfuscate: true)
  static final String botId = _CredsDev.botId;
  @EnviedField(varName: 'BUCKET_NAME', obfuscate: true)
  static final String bucketName = _CredsDev.bucketName;
  @EnviedField(varName: 'POOL_ID', obfuscate: true)
  static final String poolId = _CredsDev.poolId;
}

///These are PROD community credentials
@Envied(name: 'CredsProd', path: '.env.prod')
abstract class CredsProd {
  @EnviedField(varName: 'API_KEY', obfuscate: true)
  static final String apiKey = _CredsProd.apiKey;
  @EnviedField(varName: 'BOT_ID', obfuscate: true)
  static final String botId = _CredsProd.botId;
  @EnviedField(varName: 'BUCKET_NAME', obfuscate: true)
  static final String bucketName = _CredsProd.bucketName;
  @EnviedField(varName: 'POOL_ID', obfuscate: true)
  static final String poolId = _CredsProd.poolId;
}
