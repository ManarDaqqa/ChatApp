import 'package:encrypt/encrypt.dart' as encrypt;


class Encryption {
  static encryptAES(String text)  {
    encrypt.Key key = encrypt.Key.fromLength(16);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(text, iv: iv).base64;
    return encrypted;
  }

  static decryptAES(String text) {
    encrypt.Key key = encrypt.Key.fromLength(16);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(text, iv: iv);
    return decrypted;
  }


}

