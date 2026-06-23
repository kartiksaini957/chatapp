import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _nameKey = 'user_name';
  static const String _phoneKey = 'user_phone';
  static const String _emailKey = 'user_email';

  // ── REGISTER ──
  static Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      await cred.user?.updateDisplayName(name);
      await cred.user?.sendEmailVerification();
      // Save to Firestore so phone is available across devices/logins
      try {
        await _db.collection('users').doc(uid).set({
          'name': name,
          'email': email,
          'phone': phone,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (_) {
        // Firestore write failure should not block account creation
      }
      await _saveProfile(name: name, email: email, phone: phone);
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_firebaseError(e.code));
    } catch (e) {
      return AuthResult.error('Kuch galat hua. Dobara try karein.');
    }
  }

  // ── LOGIN ──
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;

      // Fetch phone (and name) from Firestore so profile is always in sync
      String phone = '';
      String name = user.displayName ?? '';
      try {
        final doc = await _db.collection('users').doc(user.uid).get();
        if (doc.exists) {
          phone = (doc.data()?['phone'] as String?) ?? '';
          final firestoreName = (doc.data()?['name'] as String?) ?? '';
          if (firestoreName.isNotEmpty) name = firestoreName;
        }
      } catch (_) {}

      await _saveProfile(
        name: name,
        email: user.email ?? email,
        phone: phone,
      );
      return AuthResult.success();
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_firebaseError(e.code));
    } catch (e) {
      return AuthResult.error('Kuch galat hua. Dobara try karein.');
    }
  }

  // ── RESEND VERIFICATION EMAIL ──
  static Future<AuthResult> resendVerificationEmail({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.sendEmailVerification();
      await _auth.signOut();
      return AuthResult.success(emailVerificationSent: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_firebaseError(e.code));
    } catch (e) {
      return AuthResult.error('Kuch galat hua. Dobara try karein.');
    }
  }

  // ── FORGOT PASSWORD ──
  static Future<AuthResult> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(emailVerificationSent: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_firebaseError(e.code));
    } catch (e) {
      return AuthResult.error('Kuch galat hua. Dobara try karein.');
    }
  }

  // ── LOGOUT ──
  static Future<void> logout() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
  }

  // ── CHECK IF LOGGED IN ──
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // ── GET USER NAME ──
  static Future<String> getUserName() async {
    final firebaseName = _auth.currentUser?.displayName;
    if (firebaseName != null && firebaseName.isNotEmpty) return firebaseName;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? '';
  }

  // ── GET USER PHONE ──
  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString(_phoneKey) ?? '';
    if (savedPhone.isNotEmpty) return savedPhone;

    final user = _auth.currentUser;
    if (user == null) return '';

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final phone = (doc.data()?['phone'] as String?) ?? '';
      if (phone.isNotEmpty) {
        await prefs.setString(_phoneKey, phone);
      }
      return phone;
    } catch (_) {
      return '';
    }
  }

  // ── GET USER EMAIL ──
  static Future<String> getUserEmail() async {
    final email = _auth.currentUser?.email;
    if (email != null && email.isNotEmpty) return email;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey) ?? '';
  }

  // ── GET SAVED USER ──
  static Future<Map<String, dynamic>?> getSavedUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return {
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
    };
  }

  static Future<void> _saveProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (name.isNotEmpty) await prefs.setString(_nameKey, name);
    if (email.isNotEmpty) await prefs.setString(_emailKey, email);
    if (phone.isNotEmpty) await prefs.setString(_phoneKey, phone);
  }

  static String _firebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Yeh email registered nahi hai';
      case 'wrong-password':
        return 'Password galat hai';
      case 'email-already-in-use':
        return 'Yeh email pehle se use ho raha hai';
      case 'weak-password':
        return 'Password kam se kam 6 characters ka hona chahiye';
      case 'invalid-email':
        return 'Email sahi nahi hai';
      case 'user-disabled':
        return 'Yeh account disable kar diya gaya hai';
      case 'too-many-requests':
        return 'Bahut zyada attempts. Thodi der baad try karein';
      case 'invalid-credential':
        return 'Email ya password galat hai';
      default:
        return 'Kuch galat hua. Dobara try karein.';
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final bool emailVerificationSent;
  final bool needsEmailVerification;
  final String? unverifiedEmail;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.emailVerificationSent = false,
    this.needsEmailVerification = false,
    this.unverifiedEmail,
    this.errorMessage,
  });

  factory AuthResult.success({bool emailVerificationSent = false}) =>
      AuthResult._(
          isSuccess: true, emailVerificationSent: emailVerificationSent);

  factory AuthResult.emailNotVerified({required String email}) => AuthResult._(
        isSuccess: false,
        needsEmailVerification: true,
        unverifiedEmail: email,
        errorMessage: 'Email verify nahi hua hai',
      );

  factory AuthResult.error(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}
