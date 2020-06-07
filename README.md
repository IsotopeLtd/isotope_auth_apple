# Isotope Apple Auth Service

Extends the Isotope `AuthServiceAdapter` and provides a `AppleAuthService` for authentication using `AppleSignIn` and `FirebaseAuth` backend service provider.

## Installation

Add the following dependencies to your `pubspec.yaml`:

```dart
dependences:
  isotope_auth:
    git: git://github.com/isotopeltd/isotope_auth.git
  isotope_auth_apple:
    git: git://github.com/isotopeltd/isotope_auth_apple.git
```

## Implementation

In your project, import the package:

```dart
import 'package:isotope_auth_apple/isotope_auth_apple';
```

Then instantiate a new `AppleAuthService` object:

```dart
// authService constant is used in later examples:
const AppleAuthService authService = new AppleAuthService();
```

If you are using the `Isotope` framework, you'll likely be register the `AppleAuthService` as a lazy singleton object using `registrar` service locator:

```dart
import 'package:isotope/registrar.dart';

void setup() {
  // Determine if the device has Apple Sign In available as an authentication method.
  bool appleIsAvailable = await AppleAuthAvailable.check();

  // If Apple is available, then register the AppleAuthService.
  if (appleIsAvailable) {
    Registrar.instance.registerLazySingleton<AppleAuthService>(AppleAuthService());
  }
}
```

See the [registrar documentation](https://github.com/IsotopeLtd/isotope/tree/master/lib/src/registrar) for information about registering, fetching, resetting and unregistering lazy singletons.

### Sign in

Signs in to `FirebaseAuth` using `AppleSignIn`.

Method signature:

```dart
Future<IsotopeIdentity> signIn()
```

The method will return an `IsotopeIdentity` object.

Example:

```dart
IsotopeIdentity identity = await authService.signIn({});
```

### Sign out

Signs out of `FirebaseAuth`.

Method signature:

```dart
Future<void> signOut()
```

Example:

```dart
await authService.signOut();
```

### Current identity

Returns an `IsotopeIdentity` object if the user is authenticated or `null` when not authenticated.

Method signature:

```dart
Future<IsotopeIdentity> currentIdentity()
```

Example:

```dart
IsotopeIdentity identity = authService.currentIdentity();
```

## License

This library is available as open source under the terms of the MIT License.

## Copyright

Copyright © 2020 Jurgen Jocubeit
