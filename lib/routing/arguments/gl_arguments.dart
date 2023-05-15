import '../../db/entity/party.dart';
import '../../db/entity/party_guest.dart';

class GlArguments {
  final PartyGuest partyGuest;
  final Party party;
  final String task;

  const GlArguments({required this.partyGuest, required this.party, required this.task});
}