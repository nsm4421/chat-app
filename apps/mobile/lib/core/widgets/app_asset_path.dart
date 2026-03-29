enum AppAssetPath {
  logoLight('assets/logo/domodachi-light.svg'),
  logoDark('assets/logo/domodachi-dark.svg'),
  logoMarkLight('assets/logo/domodachi-mark-light.svg'),
  logoMarkDark('assets/logo/domodachi-mark-dark.svg'),
  membersLight('assets/icons/members-light.svg'),
  membersDark('assets/icons/members-dark.svg'),
  dmLight('assets/icons/dm-light.svg'),
  dmDark('assets/icons/dm-dark.svg'),
  groupLight('assets/icons/group-light.svg'),
  groupDark('assets/icons/group-dark.svg'),
  friendAddLight('assets/icons/friend-add-light.svg'),
  friendAddDark('assets/icons/friend-add-dark.svg'),
  likeLight('assets/icons/like-light.svg'),
  likeDark('assets/icons/like-dark.svg');

  const AppAssetPath(this.value);

  final String value;
}
