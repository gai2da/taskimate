import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;

class GoogleService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
  );

  Future<List<calendar.Event>> getTasksFromGoogle() async {
    try {
      GoogleSignInAccount? user = await _googleSignIn.signInSilently();

      if (user != null) {
        final GoogleSignInAuthentication signAuth = await user.authentication;

        final auth.AuthClient authenticatedClient = auth.authenticatedClient(
          http.Client(),
          auth.AccessCredentials(
            auth.AccessToken(
              'Bearer',
              signAuth.accessToken!,
              DateTime.now().toUtc().add(Duration(hours: 1)),
            ),
            null,
            ['https://www.googleapis.com/auth/calendar.readonly'],
          ),
        );

        final calendar.Events events =
            await calendar.CalendarApi(authenticatedClient)
                .events
                .list("primary");

        print(" from googl:: ${events.items?.length ?? 0}");
        return events.items ?? [];
      }
      return [];
    } catch (e) {
      print("error $e");
      return [];
    }
  }
}
