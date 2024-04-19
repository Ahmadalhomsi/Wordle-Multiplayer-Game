import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class InvitationListener {
  final String currentUserId;
  late DatabaseReference invitationsRef;

  InvitationListener(this.currentUserId) {
    // Initialize Firebase (assuming you have already configured it)

    // Get a reference to the invitations node
    invitationsRef = FirebaseDatabase.instance.ref().child('invitations');
  }

  Stream<String?> listenForInvitations() {
    // Create a DataSnapshot stream for invitations
    final invitationStream = invitationsRef.onValue;

    return invitationStream.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        // Check for invitations for current user
        final invitations = snapshot.children;
        for (final invitation in invitations) {
          if (invitation.key == currentUserId) {
            return invitation.key; // User invited
          }
        }
      }
      return null; // Not invited yet
    });
  }


  
}
