import 'package:firebase_auth/firebase_auth.dart';
import 'auth_token_provider.dart';

class FirebaseAuthTokenProvider implements AuthTokenProvider {
  const FirebaseAuthTokenProvider();

  @override
  Future<String> getIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No authenticated user');
    return (await user.getIdToken())!;
  }
}
