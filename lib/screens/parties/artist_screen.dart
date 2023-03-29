import 'package:flutter/material.dart';

import '../../db/entity/party.dart';
import '../../utils/network_utils.dart';
import '../../widgets/ui/button_widget.dart';

class ArtistScreen extends StatefulWidget {
  final Party party;

  const ArtistScreen({required this.party, Key? key}) : super(key: key);

  @override
  State<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          title: const Text(''),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: _buildBody(context));
  }

  _buildBody(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          width: double.infinity,
          child: Hero(
            tag: widget.party.id,
            child: Image.network(
              widget.party.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Text(widget.party.name.toLowerCase(),
              textAlign: TextAlign.start,
              softWrap: true,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 26,
              )),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: Text(widget.party.description.toLowerCase(),
              textAlign: TextAlign.start,
              softWrap: true,
              style: TextStyle(
                color: Theme.of(context).primaryColorLight,
                fontSize: 20,
              )),
        ),
        const SizedBox(height: 10),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.stretch,
        //     children: [
        //       ButtonWidget(text: 'lounge', onClicked: () {} ),
        //       const SizedBox(height: 10),
        //     ],
        //   ),
        // ),
        widget.party.ticketUrl.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ButtonWidget(
                  text: 'buy tickets',
                  onClicked: () {
                    final uri = Uri.parse(widget.party.ticketUrl);
                    NetworkUtils.launchInBrowser(uri);
                  }),
              const SizedBox(height: 10),
            ],
          ),
        )
            : const SizedBox(),
        widget.party.listenUrl.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ButtonWidget(
                        text: 'listen' + findListenSource(widget.party.listenUrl),
                        onClicked: () {
                          final uri = Uri.parse(widget.party.listenUrl);
                          NetworkUtils.launchInBrowser(uri);
                        }),
                    const SizedBox(height: 10),
                  ],
                ),
              )
            : const SizedBox(),
        widget.party.instagramUrl.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ButtonWidget(
                        text: 'social profile',
                        onClicked: () {
                          final uri = Uri.parse(widget.party.instagramUrl);
                          NetworkUtils.launchInBrowser(uri);
                        }),
                    const SizedBox(height: 10),
                  ],
                ),
              )
            : const SizedBox(),
        const SizedBox(height: 10),
      ],
    );
  }

  String findListenSource(String listenUrl) {
    if(listenUrl.contains('spotify')){
        return ' on spotify';
    } else if(listenUrl.contains('soundcloud')){
      return ' on soundcloud';
    } if(listenUrl.contains('youtube')){
      return ' on youtube';
    } else{
      return '';
    }
  }
}
