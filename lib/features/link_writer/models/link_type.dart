import 'link_input_mode.dart';

final class LinkType {
  const LinkType({
    required this.id,
    required this.label,
    required this.inputMode,
    required this.placeholder,
    required this.description,
    required this.iconName,
    this.baseUrl,
  });

  final String id;
  final String label;
  final LinkInputMode inputMode;
  final String? baseUrl;
  final String placeholder;
  final String description;
  final String iconName;

  static const instagram = LinkType(
    id: 'instagram',
    label: 'Instagram',
    inputMode: LinkInputMode.username,
    baseUrl: 'https://instagram.com',
    placeholder: '@romrom_official',
    description: '계정명으로 Instagram 링크를 만듭니다.',
    iconName: 'instagram',
  );

  static const linkedin = LinkType(
    id: 'linkedin',
    label: 'LinkedIn',
    inputMode: LinkInputMode.fullUrl,
    placeholder: 'linkedin.com/in/username',
    description: '프로필 URL 전체를 입력합니다.',
    iconName: 'linkedin',
  );

  static const github = LinkType(
    id: 'github',
    label: 'GitHub',
    inputMode: LinkInputMode.fullUrl,
    placeholder: 'github.com/username',
    description: 'GitHub 프로필 또는 저장소 URL을 입력합니다.',
    iconName: 'github',
  );

  static const linktree = LinkType(
    id: 'linktree',
    label: 'Linktree',
    inputMode: LinkInputMode.fullUrl,
    placeholder: 'linktr.ee/username',
    description: 'Linktree URL을 입력합니다.',
    iconName: 'linktree',
  );

  static const portfolio = LinkType(
    id: 'portfolio',
    label: 'Portfolio',
    inputMode: LinkInputMode.fullUrl,
    placeholder: 'my-portfolio.com',
    description: '포트폴리오 또는 개인 웹사이트 URL을 입력합니다.',
    iconName: 'portfolio',
  );

  static const custom = LinkType(
    id: 'custom',
    label: '직접 입력',
    inputMode: LinkInputMode.fullUrl,
    placeholder: 'example.com/profile',
    description: '원하는 URL을 직접 입력합니다.',
    iconName: 'link',
  );

  static const values = [
    instagram,
    linkedin,
    github,
    linktree,
    portfolio,
    custom,
  ];
}
