import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/main.dart';
import 'package:bloc/utils/constants.dart';
import 'package:bloc/utils/network_utils.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../db/entity/bloc.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';

class VenueBanner extends StatefulWidget {
  static const String _TAG = 'VenueBanner';

  final String blocServiceId;

  VenueBanner({Key? key, required this.blocServiceId}) : super(key: key);

  @override
  State<VenueBanner> createState() => _VenueBannerState();
}

class _VenueBannerState extends State<VenueBanner> {
  static const String _TAG = 'VenueBanner';

  late Bloc mBloc;
  late BlocService mBlocService;
  String mAddress = '';
  var _isBlocLoading = true;

  @override
  void initState() {
    FirestoreHelper.pullBlocServiceById(widget.blocServiceId).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

        mBlocService = Fresh.freshBlocServiceMap(data, false);

        FirestoreHelper.pullBlocById(mBlocService.blocId).then((res) {
          if (res.docs.isNotEmpty) {
            DocumentSnapshot document = res.docs[0];
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;
            mBloc = Fresh.freshBlocMap(data, false);

            setState(() {
              mAddress =
                  '${mBloc.name}, ${mBloc.addressLine1}, ${mBloc.addressLine2}';
              _isBlocLoading = false;
            });
          }
        });
      } else {
        Logx.em(_TAG, 'bloc service not found!');
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.blocServiceId,
          child: _isBlocLoading
              ? const LoadingWidget()
              : Card(
                  elevation: 5,
                  color: Colors.black,
                  child: SizedBox(
                    height: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              final double destinationLatitude = mBloc.latitude;
                              final double destinationLongitude = mBloc.longitude;

                              final url =
                                  'https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude';
                              final uri = Uri.parse(url);
                              NetworkUtils.launchInBrowser(uri);
                            },
                            child: SizedBox(
                              height: 200,
                              child: kIsWeb
                                  ? FadeInImage(
                                      placeholder: const AssetImage(
                                          'assets/icons/logo.png'),
                                      image: NetworkImage(mBloc.mapImageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: mBloc.mapImageUrl,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          const FadeInImage(
                                        placeholder:
                                            AssetImage('assets/images/logo.png'),
                                        image:
                                            AssetImage('assets/images/logo.png'),
                                        fit: BoxFit.cover,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0, vertical: 1),
                                  child: Text(
                                    mBloc.name.toLowerCase(),
                                    textAlign: TextAlign.end,
                                    style: const TextStyle(
                                        color: Constants.primary,
                                        fontFamily: Constants.fontDefault,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 2),
                                child: Text(
                                  '📍 ${mAddress.toLowerCase()}',
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  maxLines: 2,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Constants.lightPrimary),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 2),
                                child: GestureDetector(
                                  onTap: () {
                                    final url = "tel:+91${mBlocService.primaryPhone.toInt()}";
                                    final uri = Uri.parse(url);
                                    try{
                                      launchUrl(uri);
                                    } catch (e){
                                      Logx.em(_TAG, e.toString());
                                    }
                                  },
                                  child: Text(
                                    '📞 +91-${mBlocService.primaryPhone.toInt()}',
                                    textAlign: TextAlign.end,
                                    maxLines: 1,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Constants.lightPrimary),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _showDirectionsButton(context)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  _showDirectionsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Constants.primary,
          foregroundColor: Constants.darkPrimary,
          shadowColor: Colors.white10,
          elevation: 3,
          minimumSize: const Size.fromHeight(60),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
        ),
        onPressed: () {
          final double destinationLatitude = mBloc.latitude;
          final double destinationLongitude = mBloc.longitude;

          final url =
              'https://www.google.com/maps/dir/?api=1&destination=$destinationLatitude,$destinationLongitude';
          final uri = Uri.parse(url);
          NetworkUtils.launchInBrowser(uri);
        },
        icon: const Icon(
          Icons.map,
          size: 24.0,
        ),
        label: Text(
          'let\'s go 🚀',
          style: const TextStyle(fontSize: 20, color: Constants.darkPrimary),
        ),
      ),
    );
  }
}
