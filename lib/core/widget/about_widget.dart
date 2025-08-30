import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/util/teb_url_manager.dart';

class AboutWidget extends StatefulWidget {
  const AboutWidget({super.key});

  @override
  State<AboutWidget> createState() => _AboutWidgetState();
}

class _AboutWidgetState extends State<AboutWidget> {
  @override
  Widget build(BuildContext context) {
    var links = [
      IconButton(
        icon: const Icon(FontAwesomeIcons.linkedin),
        iconSize: 26.0,
        onPressed: () => TebUrlManager.launchUrl(url: 'https://www.linkedin.com/in/marcosmhs/'),
      ),
      IconButton(
        icon: const Icon(FontAwesomeIcons.m),
        iconSize: 26.0,
        onPressed: () => TebUrlManager.launchUrl(url: 'https://www.marcosmhs.com.br/'),
      ),
      IconButton(
        icon: const Icon(FontAwesomeIcons.github),
        iconSize: 26.0,
        onPressed: () => TebUrlManager.launchUrl(url: 'https://github.com/marcosmhs/'),
      ),
    ];

    return Column(
      children: [
        TebText(
          'Desenvolvido por Marcos H. Silva',
          textSize: 20,
          padding: EdgeInsets.symmetric(vertical: 10),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: links),
        const SizedBox(height: 20),
      ],
    );
  }
}
