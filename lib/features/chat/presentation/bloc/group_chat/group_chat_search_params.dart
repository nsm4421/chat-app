final class GroupChatSearchParams {
  const GroupChatSearchParams({
    this.hostedOnly = false,
  });

  final bool hostedOnly;

  static const defaults = GroupChatSearchParams();

  GroupChatSearchParams copyWith({
    bool? hostedOnly,
  }) {
    return GroupChatSearchParams(
      hostedOnly: hostedOnly ?? this.hostedOnly,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is GroupChatSearchParams && hostedOnly == other.hostedOnly;
  }

  @override
  int get hashCode => hostedOnly.hashCode;
}
