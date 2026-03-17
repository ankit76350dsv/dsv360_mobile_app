import 'package:dsv360/core/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsiteRow extends StatelessWidget {
	final IconData icon;
	final String value;

	const WebsiteRow({
		super.key,
		required this.icon,
		required this.value,
	});

	@override
	Widget build(BuildContext context) {
		final customColors = Theme.of(context).custom;

		final websiteUrl = value.startsWith('http') ? value : 'https://$value';

		return Row(
			children: [
				Icon(icon, size: 18, color: customColors.textSecondary),
				const SizedBox(width: 8),
				TextButton(
					onPressed: () async {
						final uri = Uri.parse(websiteUrl);
						if (await canLaunchUrl(uri)) {
							await launchUrl(uri, mode: LaunchMode.externalApplication);
						}
					},
					style: TextButton.styleFrom(
						padding: EdgeInsets.zero,
						minimumSize: const Size(0, 0),
						tapTargetSize: MaterialTapTargetSize.shrinkWrap,
					),
					child: Text(
						'Open website',
						style: TextStyle(
							fontSize: 14,
							color: customColors.primary,
							decoration: TextDecoration.underline,
						),
					),
				),
			],
		);
	}
}
