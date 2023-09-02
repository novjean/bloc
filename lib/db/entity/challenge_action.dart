class ChallengeAction{
  final String id;
  final String challengeId;
  final int buttonCount;
  final String buttonTitle;
  final String action;
  final String actionType;

//<editor-fold desc="Data Methods">
  const ChallengeAction({
    required this.id,
    required this.challengeId,
    required this.buttonCount,
    required this.buttonTitle,
    required this.action,
    required this.actionType,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChallengeAction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          challengeId == other.challengeId &&
          buttonCount == other.buttonCount &&
          buttonTitle == other.buttonTitle &&
          action == other.action &&
          actionType == other.actionType);

  @override
  int get hashCode =>
      id.hashCode ^
      challengeId.hashCode ^
      buttonCount.hashCode ^
      buttonTitle.hashCode ^
      action.hashCode ^
      actionType.hashCode;

  @override
  String toString() {
    return 'ChallengeAction{' +
        ' id: $id,' +
        ' challengeId: $challengeId,' +
        ' buttonCount: $buttonCount,' +
        ' buttonTitle: $buttonTitle,' +
        ' action: $action,' +
        ' actionType: $actionType,' +
        '}';
  }

  ChallengeAction copyWith({
    String? id,
    String? challengeId,
    int? buttonCount,
    String? buttonTitle,
    String? action,
    String? actionType,
  }) {
    return ChallengeAction(
      id: id ?? this.id,
      challengeId: challengeId ?? this.challengeId,
      buttonCount: buttonCount ?? this.buttonCount,
      buttonTitle: buttonTitle ?? this.buttonTitle,
      action: action ?? this.action,
      actionType: actionType ?? this.actionType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'challengeId': this.challengeId,
      'buttonCount': this.buttonCount,
      'buttonTitle': this.buttonTitle,
      'action': this.action,
      'actionType': this.actionType,
    };
  }

  factory ChallengeAction.fromMap(Map<String, dynamic> map) {
    return ChallengeAction(
      id: map['id'] as String,
      challengeId: map['challengeId'] as String,
      buttonCount: map['buttonCount'] as int,
      buttonTitle: map['buttonTitle'] as String,
      action: map['action'] as String,
      actionType: map['actionType'] as String,
    );
  }

//</editor-fold>
}