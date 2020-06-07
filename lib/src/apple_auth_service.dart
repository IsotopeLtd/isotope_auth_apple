import 'dart:async';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:isotope_auth/isotope_auth.dart';

class AppleAuthService extends AuthServiceAdapter {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<IsotopeIdentity> currentIdentity() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return _identityFromFirebase(user);
  }

  @override
  Stream<IsotopeIdentity> get onAuthStateChanged {
    authStateChangedController.stream;
    return _firebaseAuth.onAuthStateChanged.map(_identityFromFirebase);
  }

  @override
  AuthProvider get provider {
    return AuthProvider.anonymous;
  }

  @override
  Future<IsotopeIdentity> signIn(Map<String, dynamic> credentials) async {
    List<Scope> scopes = credentials['scopes'];
    if (scopes = null) scopes = const [];

    const APPLE_PROVIDER_ID = 'apple.com';

    final AuthorizationResult result = await AppleSignIn.performRequests(
      [AppleIdRequest(requestedScopes: scopes)]
    );
    
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider(providerId: APPLE_PROVIDER_ID);
        final credential = oAuthProvider.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken: String.fromCharCodes(appleIdCredential.authorizationCode),
        );
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;

        if (scopes.contains(Scope.fullName)) {
          final updateUser = UserUpdateInfo();
          updateUser.displayName = 
              '${appleIdCredential.fullName.givenName} ${appleIdCredential.fullName.familyName}';
          await firebaseUser.updateProfile(updateUser);
        }
        
        return _identityFromFirebase(firebaseUser);
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );
      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
    }
    return null;
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  IsotopeIdentity _identityFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }
    return IsotopeIdentity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }
}
