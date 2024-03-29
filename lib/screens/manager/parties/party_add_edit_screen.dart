import 'dart:io';

import 'package:bloc/db/entity/ad_campaign.dart';
import 'package:bloc/db/entity/bloc_service.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/utils/date_time_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/challenge.dart';
import '../../../db/entity/genre.dart';
import '../../../db/entity/lounge.dart';
import '../../../db/entity/organizer.dart';
import '../../../db/entity/party.dart';
import '../../../db/entity/party_interest.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../utils/network_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import 'manage_tix_tiers_screen.dart';

class PartyAddEditScreen extends StatefulWidget {
  Party party;
  String task;

  PartyAddEditScreen({key, required this.party, required this.task})
      : super(key: key);

  @override
  _PartyAddEditScreenState createState() => _PartyAddEditScreenState();
}

class _PartyAddEditScreenState extends State<PartyAddEditScreen> {
  static const String _TAG = 'PartyAddEditScreen';

  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';
  String storyImagePath = '';

  List<BlocService> blocServices = [];
  List<String> blocServiceNames = [];
  late String _sBlocServiceName;
  late String _sBlocServiceId;
  bool _isBlocServicesLoading = true;

  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();
  DateTime sEndGuestListDateTime = DateTime.now();
  bool _isGuestListDateBeingSet = true;

  DateTime sDate = DateTime.now();

  TimeOfDay sTimeOfDay = TimeOfDay.now();
  bool _isStartDateBeingSet = true;
  bool _isEndDateBeingSet = true;

  late String sGuestCount;
  List<String> guestCounts = [];

  late String _sPartyType;
  List<String> partyTypes = ['artist', 'event'];

  String sGenre = '';
  List<Genre> mGenres = [];
  List<String> mGenreNames = [''];
  bool _isGenresLoading = true;

  List<Challenge> mChallenges = [];
  List<String> mChallengeNames = ['none'];
  bool _isChallengesLoading = true;
  String sOverrideChallenge = 'none';

  List<Party> mArtists = [];
  bool _isArtistsLoading = true;
  List<String> sArtistNames = [];
  List<Party> sArtists = [];
  List<String> sArtistIds = [];

  List<Organizer> mOrganizers = [];
  bool _isOrganizersLoading = true;
  List<String> sOrganizerNames = [];
  List<Organizer> sOrganizers = [];
  List<String> sOrganizerIds = [];

  List<Lounge> mLounges = [];
  List<Lounge> sLounges = [];
  List<String> sLoungeIds = [];
  List<String> sLoungeNames = [];

  late Lounge sLounge;
  late String sLoungeId;
  List<String> mLoungeNames = [];
  bool _isLoungesLoading = true;

  PartyInterest mPartyInterest = Dummy.getDummyPartyInterest();
  bool _isPartyInterestLoading = true;

  List<String> mImageUrls = [];
  List<String> oldImageUrls = [];

  double mBookingFee = 0;

  @override
  void initState() {
    mBookingFee = widget.party.bookingFeePercent * 100;
    _sPartyType = widget.party.type;
    mImageUrls.addAll(widget.party.imageUrls);

    FirestoreHelper.pullAllBlocServices().then((res) {
      Logx.i(_TAG, "successfully pulled in all bloc services ");

      if (res.docs.isNotEmpty) {
        List<BlocService> _blocServices = [];
        List<String> _blocServiceNames = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);

          if(widget.party.blocServiceId.isNotEmpty){
            if(blocService.id == widget.party.blocServiceId){
              _sBlocServiceId = blocService.id;
              _sBlocServiceName = blocService.name;
            }
          } else {
            if (i == 0) {
              _sBlocServiceId = blocService.id;
              _sBlocServiceName = blocService.name;
            }
          }

          _blocServiceNames.add(blocService.name);
          _blocServices.add(blocService);
        }

        setState(() {
          blocServiceNames = _blocServiceNames;
          blocServices = _blocServices;
          _isBlocServicesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no bloc services found!');
        setState(() {
          _isBlocServicesLoading = false;
        });
      }
    });

    FirestoreHelper.pullGenres().then((res) {
      Logx.i(_TAG, "successfully pulled in all genres ");

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Genre genre = Fresh.freshGenreMap(data, false);
          mGenres.add(genre);
          mGenreNames.add(genre.name);

          if (widget.party.genre == genre.name) {
            sGenre = genre.name;
          }
        }

        if (sGenre.isEmpty) {
          if (widget.party.genre.isNotEmpty) {
            // clearing out faulty data
            widget.party = widget.party.copyWith(genre: '');
          }
        }

        if (mounted) {
          setState(() {
            _isGenresLoading = false;
          });
        }
      } else {
        Logx.i(_TAG, 'no genres found!');
        if (mounted) {
          setState(() {
            _isGenresLoading = false;
          });
        }
      }
    });

    FirestoreHelper.pullChallenges().then((res) {
      if (res.docs.isNotEmpty) {
        Logx.i(_TAG, "successfully pulled in all challenges");

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Challenge challenge = Fresh.freshChallengeMap(data, false);
          mChallenges.add(challenge);
          mChallengeNames.add(challenge.title);

          if (challenge.level == widget.party.overrideChallengeNum) {
            sOverrideChallenge = challenge.title;
          }
        }

        setState(() {
          _isChallengesLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no challenges found, setting default');
        setState(() {
          _isChallengesLoading = false;
        });
      }
    });

    sArtistIds = widget.party.artistIds;
    FirestoreHelper.pullPartyArtists().then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Party artist = Fresh.freshPartyMap(data, false);
          mArtists.add(artist);

          if (sArtistIds.contains(artist.id)) {
            sArtists.add(artist);
            sArtistNames.add('${artist.name} [${artist.genre}]');
          }
        }

        setState(() {
          _isArtistsLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no artists found!');
        setState(() {
          _isArtistsLoading = false;
        });
      }
    });

    sOrganizerIds = widget.party.organizerIds;
    FirestoreHelper.pullOrganizers().then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final Organizer organizer = Fresh.freshOrganizerMap(data, false);
          mOrganizers.add(organizer);

          if (sOrganizerIds.contains(organizer.id)) {
            sOrganizers.add(organizer);
            sOrganizerNames.add(organizer.name);
          }
        }

        setState(() {
          _isOrganizersLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no organizers found!');
        setState(() {
          _isOrganizersLoading = false;
        });
      }
    });

    FirestoreHelper.pullPartyInterest(widget.party.id).then((res) {
      if (res.docs.isNotEmpty) {
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        mPartyInterest = Fresh.freshPartyInterestMap(data, false);
        setState(() {
          _isPartyInterestLoading = false;
        });
      } else {
        setState(() {
          _isPartyInterestLoading = false;
        });
      }
    });

    sLounge = Dummy.getDummyLounge();
    sLoungeId = widget.party.loungeId;
    sLoungeIds.add(sLoungeId);

    FirestoreHelper.pullLounges().then((res) {
      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
          final Lounge lounge = Fresh.freshLoungeMap(map, false);
          mLounges.add(lounge);
          mLoungeNames.add(lounge.name);
          if (lounge.id == sLoungeId) {
            sLounge = lounge;
            sLounges.add(lounge);
            sLoungeNames.add(lounge.name);
          }
        }
        setState(() {
          _isLoungesLoading = false;
        });
      } else {
        setState(() {
          _isLoungesLoading = false;
        });
      }
    });

    for (int i = 1; i <= 10; i++) {
      guestCounts.add(i.toString());
    }
    sGuestCount = widget.party.guestListCount.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            titleSpacing: 0,
            title: AppBarTitle(
              title: '${widget.task} party',
            )),
        body: _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return _isBlocServicesLoading && _isGenresLoading &&
        _isChallengesLoading && _isLoungesLoading &&
        _isPartyInterestLoading &&
        _isArtistsLoading &&
        _isOrganizersLoading
        ? const LoadingWidget()
        : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ProfileWidget(
                    imagePath:
                        imagePath.isEmpty ? widget.party.imageUrl : imagePath,
                    isEdit: true,
                    onClicked: () async {
                      final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 96,
                          maxHeight: 800,
                          maxWidth: 800);
                      if (image == null) return;

                      final directory =
                          await getApplicationDocumentsDirectory();
                      final name = basename(image.path);
                      final imageFile = File('${directory.path}/$name');
                      final newImage =
                          await File(image.path).copy(imageFile.path);

                      oldImageUrl = widget.party.imageUrl;
                      newImageUrl = await FirestorageHelper.uploadFile(
                          FirestorageHelper.PARTY_IMAGES,
                          StringUtils.getRandomString(28),
                          newImage);

                      if (oldImageUrl.isNotEmpty) {
                        FirestorageHelper.deleteFile(oldImageUrl);
                      }

                      if (mImageUrls.isNotEmpty) {
                        mImageUrls[0] = newImageUrl;
                      } else {
                        mImageUrls.add(newImageUrl);
                      }

                      widget.party = widget.party.copyWith(
                          imageUrl: newImageUrl, imageUrls: mImageUrls);

                      setState(() {
                        imagePath = imageFile.path;
                      });
                    },
                  ),
                  ProfileWidget(
                    imagePath: storyImagePath.isEmpty
                        ? widget.party.storyImageUrl
                        : storyImagePath,
                    isEdit: true,
                    onClicked: () async {
                      final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 100,
                          maxHeight: 1920,
                          maxWidth: 1080);
                      if (image == null) return;

                      final directory =
                          await getApplicationDocumentsDirectory();
                      final name = basename(image.path);
                      final imageFile = File('${directory.path}/$name');
                      final newImage =
                          await File(image.path).copy(imageFile.path);

                      String tempImageUrl = await FirestorageHelper.uploadFile(
                          FirestorageHelper.PARTY_STORY_IMAGES,
                          StringUtils.getRandomString(28),
                          newImage);

                      setState(() {
                        storyImagePath = imageFile.path;

                        if (widget.party.storyImageUrl.isNotEmpty) {
                          FirestorageHelper.deleteFile(
                              widget.party.storyImageUrl);
                        }

                        widget.party =
                            widget.party.copyWith(storyImageUrl: tempImageUrl);
                        FirestoreHelper.pushParty(widget.party);
                        Logx.ist(_TAG, 'updated party story image');
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'use story : ',
                    style: TextStyle(fontSize: 15.0),
                  ), //Text
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Checkbox(
                      value: widget.party.showStoryImageUrl,
                      onChanged: (value) {
                        setState(() {
                          widget.party = widget.party.copyWith(showStoryImageUrl: value);
                        });
                      },
                    ),
                  ),
                  const Text(
                    'square : ',
                    style: TextStyle(fontSize: 15.0),
                  ), //Text
                  Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Checkbox(
                      value: widget.party.isSquare,
                      onChanged: (value) {
                        setState(() {
                          widget.party = widget.party.copyWith(isSquare: value);
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                ButtonWidget(
                  text: mImageUrls.isEmpty? 'pick photos' :'${mImageUrls.length} photos',
                  onClicked: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 96,
                        maxHeight: 800,
                        maxWidth: 800);
                    if (image == null) return;

                    final directory =
                    await getApplicationDocumentsDirectory();
                    final name = basename(image.path);
                    final imageFile = File('${directory.path}/$name');
                    final newImage =
                    await File(image.path).copy(imageFile.path);

                    newImageUrl = await FirestorageHelper.uploadFile(
                        FirestorageHelper.PARTY_IMAGES,
                        StringUtils.getRandomString(28),
                        newImage);

                    mImageUrls.add(newImageUrl);

                    setState(() {
                      widget.party =
                          widget.party.copyWith(imageUrls: mImageUrls);
                      FirestoreHelper.pushParty(widget.party);
                      Logx.ist(_TAG, 'party is updated in firebase');
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: SizedBox.fromSize(
                    size: const Size(56, 56),
                    child: ClipOval(
                      child: Material(
                        color: Colors.redAccent,
                        child: InkWell(
                          splashColor: Colors.red,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('photos'),
                                    content: _photosListDialog(),
                                  );
                                });
                          },
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.delete_forever),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'name *',
                text: widget.party.name,
                onChanged: (name) =>
                    widget.party = widget.party.copyWith(name: name),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'type',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        key: const ValueKey('party_type'),
                        decoration: InputDecoration(
                            errorStyle: const TextStyle(
                                color: Constants.errorColor, fontSize: 16.0),
                            hintText: 'please select party type',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        isEmpty: _sPartyType == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sPartyType,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                _sPartyType = newValue!;

                                widget.party =
                                    widget.party.copyWith(type: _sPartyType);
                                state.didChange(newValue);
                              });
                            },
                            items: partyTypes.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'event name',
                maxLength: 50,
                text: widget.party.eventName,
                onChanged: (eventName) =>
                    widget.party = widget.party.copyWith(eventName: eventName),
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'chapter/country',
                text: widget.party.chapter,
                onChanged: (text) =>
                    widget.party = widget.party.copyWith(chapter: text),
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'lounge',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  MultiSelectDialogField(
                    items: mLounges
                        .map((e) => MultiSelectItem(e, e.name))
                        .toList(),
                    initialValue: sLounges.map((e) => e).toList(),
                    listType: MultiSelectListType.CHIP,
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                    title: const Text('select lounge'),
                    buttonText: const Text(
                      'select',
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 0.0,
                      ),
                    ),
                    searchable: true,
                    onConfirm: (values) {
                      sLounges = values;
                      sLoungeIds = [];
                      sLoungeNames = [];

                      for (Lounge lounge in sLounges) {
                        sLoungeIds.add(lounge.id);
                        sLoungeNames.add(lounge.name);
                      }

                      if (sLoungeIds.isEmpty) {
                        Logx.i(_TAG, 'no lounges selected');
                        widget.party = widget.party.copyWith(loungeId: '');
                      } else {
                        widget.party =
                            widget.party.copyWith(loungeId: sLoungeIds.first);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'genre',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        key: const ValueKey('party_genre'),
                        decoration: InputDecoration(
                            errorStyle: const TextStyle(
                                color: Constants.errorColor, fontSize: 16.0),
                            hintText: 'please select party genre',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        isEmpty: sGenre == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: sGenre,
                            isDense: true,
                            onChanged: (String? newValue) {
                              sGenre = newValue!;
                              widget.party =
                                  widget.party.copyWith(genre: sGenre);
                              state.didChange(newValue);
                            },
                            items: mGenreNames.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'description',
                text: widget.party.description,
                maxLength: 5000,
                maxLines: 8,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(description: value);
                },
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'organizers',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  MultiSelectDialogField(
                    items: mOrganizers
                        .map((e) => MultiSelectItem(e, e.name.toLowerCase()))
                        .toList(),
                    initialValue: sOrganizers.map((e) => e).toList(),
                    listType: MultiSelectListType.CHIP,
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                    title: const Text('organizers'),
                    buttonText: const Text(
                      'select',
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 0.0,
                      ),
                    ),
                    searchable: true,
                    onConfirm: (values) {
                      sOrganizers = values;
                      sOrganizerIds = [];
                      sOrganizerNames = [];

                      for (Organizer organizer in sOrganizers) {
                        sOrganizerIds.add(organizer.id);
                        sOrganizerNames.add(organizer.name);
                      }

                      if (sOrganizerIds.isEmpty) {
                        Logx.i(_TAG, 'no organizers selected');
                        widget.party = widget.party.copyWith(organizerIds: []);
                      } else {
                        widget.party =
                            widget.party.copyWith(organizerIds: sOrganizerIds);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'artists',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  MultiSelectDialogField(
                    items: mArtists
                        .map((e) => MultiSelectItem(e,
                            '${e.name.toLowerCase()} | ${e.genre.toLowerCase()}'))
                        .toList(),
                    initialValue: sArtists.map((e) => e).toList(),
                    listType: MultiSelectListType.CHIP,
                    buttonIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade700,
                    ),
                    title: const Text('performing artists'),
                    buttonText: const Text(
                      'select',
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      border: Border.all(
                        width: 0.0,
                      ),
                    ),
                    searchable: true,
                    onConfirm: (values) {
                      sArtists = values as List<Party>;
                      sArtistIds = [];
                      sArtistNames = [];

                      for (Party artist in sArtists) {
                        sArtistIds.add(artist.id);
                        sArtistNames.add(artist.name);
                      }

                      if (sArtistIds.isEmpty) {
                        Logx.i(_TAG, 'no artists selected');
                        widget.party = widget.party.copyWith(artistIds: []);
                      } else {
                        widget.party =
                            widget.party.copyWith(artistIds: sArtistIds);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          'bloc',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        key: const ValueKey('bloc_service_id'),
                        decoration: InputDecoration(
                            errorStyle: const TextStyle(
                                color: Constants.errorColor, fontSize: 16.0),
                            hintText: 'please select bloc service',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                        isEmpty: _sBlocServiceName == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sBlocServiceName,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                _sBlocServiceName = newValue!;

                                for (BlocService service in blocServices) {
                                  if (service.name == _sBlocServiceName) {
                                    _sBlocServiceId = service.id;
                                  }
                                }

                                widget.party = widget.party
                                    .copyWith(blocServiceId: _sBlocServiceId);
                                state.didChange(newValue);
                              });
                            },
                            items: blocServiceNames.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'instagram url',
                text: widget.party.instagramUrl,
                maxLines: 1,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(instagramUrl: value);
                },
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'ticket url',
                text: widget.party.ticketUrl,
                maxLines: 1,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(ticketUrl: value);
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    const Text(
                      'disable ticket link : ',
                      style: TextStyle(fontSize: 17.0),
                    ), //Text
                    const SizedBox(width: 10), //SizedBox
                    Checkbox(
                      value: widget.party.isTicketsDisabled,
                      onChanged: (value) {
                        setState(() {
                          widget.party = widget.party.copyWith(isTicketsDisabled: value);
                        });
                      },
                    ),
                  ],),
                   ButtonWidget(
                     text: 'check',
                     onClicked: () {
                       if(widget.party.ticketUrl.isNotEmpty){
                         final uri = Uri.parse(widget.party.ticketUrl);
                         NetworkUtils.launchInBrowser(uri);
                       }
                   },)
                   //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'listen url',
                text: widget.party.listenUrl,
                maxLines: 1,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(listenUrl: value);
                },
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'interest initial count',
                text: mPartyInterest.initCount.toString(),
                maxLines: 1,
                onChanged: (value) {
                  int? initialCount = int.tryParse(value);
                  mPartyInterest =
                      mPartyInterest.copyWith(initCount: initialCount);
                  FirestoreHelper.pushPartyInterest(mPartyInterest);
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('interest user count: ${mPartyInterest.userIds.length}'),
                  ButtonWidget(
                    text: 'reset',
                    onClicked: () {
                      mPartyInterest = mPartyInterest.copyWith(initCount: 0);
                      mPartyInterest.userIds = [];
                      FirestoreHelper.pushPartyInterest(mPartyInterest);
                      setState(() {});
                    },
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('share count: ${widget.party.shareCount}'),
                  ButtonWidget(
                    text: 'reset',
                    onClicked: () {
                      widget.party = widget.party.copyWith(shareCount: 0);
                      setState(() {});
                    },
                  )
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('view count: ${widget.party.views}'),
                  ButtonWidget(
                    text: 'reset',
                    onClicked: () {
                      widget.party = widget.party.copyWith(views: 0);
                      setState(() {});
                    },
                  )
                ],
              ),
              const SizedBox(height: 24),
              dateTimeContainer(context, 'start'),
              const SizedBox(height: 24),
              dateTimeContainer(context, 'end'),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isActive,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isActive: value);
                      });

                      if (!value! && (widget.party.storyImageUrl.isNotEmpty ||
                          widget.party.imageUrls.length > 1)) {
                        _showDeleteExtraPhotosDialog(context);
                      }
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Text(
                    'tba : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isTBA,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isTBA: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Text(
                    'big act : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isBigAct,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isBigAct: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Text(
                    'tix event : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isTix,
                    onChanged: (value) {
                      setState(() {
                        widget.party = widget.party.copyWith(isTix: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 12),
              TextFieldWidget(
                label: 'booking fee %',
                text: '$mBookingFee',
                onChanged: (text) {
                  try {
                    double value = (double.parse(text)) / 100;
                    widget.party =
                        widget.party.copyWith(bookingFeePercent: value);

                    setState(() {
                      mBookingFee = value * 100;
                    });
                  } catch (e) {
                    Logx.em(_TAG, 'number format exception booking fee');
                  }
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'guest list active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isGuestListActive,
                    onChanged: (value) {
                      setState(() {
                        widget.party =
                            widget.party.copyWith(isGuestListActive: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Text(
                    'guest list full : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isGuestListFull,
                    onChanged: (value) {
                      setState(() {
                        widget.party =
                            widget.party.copyWith(isGuestListFull: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Text(
                    'guests count restricted : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isGuestsCountRestricted,
                    onChanged: (value) {
                      setState(() {
                        widget.party =
                            widget.party.copyWith(isGuestsCountRestricted: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'guests count',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        key: const ValueKey('guest_count'),
                        decoration: InputDecoration(
                            fillColor: Colors.white,
                            errorStyle: const TextStyle(
                                color: Constants.errorColor, fontSize: 16.0),
                            hintText: 'please select guest count',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(width: 0.0),
                            )),
                        isEmpty: sGuestCount == '',
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: sGuestCount,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() {
                                sGuestCount = newValue!;
                                int count = int.parse(sGuestCount);

                                widget.party = widget.party
                                    .copyWith(guestListCount: count);
                                state.didChange(newValue);
                              });
                            },
                            items: guestCounts.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              dateTimeContainer(context, 'guestListEndTime'),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'email required : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isEmailRequired,
                    onChanged: (value) {
                      setState(() {
                        widget.party =
                            widget.party.copyWith(isEmailRequired: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'guest list rules',
                text: widget.party.guestListRules,
                maxLines: 5,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(guestListRules: value);
                },
              ),
              const SizedBox(height: 24),
              TextFieldWidget(
                label: 'club rules',
                text: widget.party.clubRules,
                maxLines: 5,
                onChanged: (value) {
                  widget.party = widget.party.copyWith(clubRules: value);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'ad campaign : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isAdCampaignRunning,
                    onChanged: (value) {

                      if(value!){
                        List<String> imageUrls = [];
                        if(widget.party.storyImageUrl.isNotEmpty){
                          imageUrls.add(widget.party.storyImageUrl);
                        } else {
                          imageUrls.addAll(widget.party.imageUrls);
                        }

                        // create an ad campaign
                        AdCampaign adCampaign = Dummy.getDummyAdCampaign();
                        adCampaign = adCampaign.copyWith(
                            name: widget.party.name,
                            imageUrls: imageUrls,
                            isStorySize: true,
                            isActive: true,
                            isPartyAd: true,
                            partyId: widget.party.id,
                            endTime: widget.party.endTime
                        );
                        FirestoreHelper.pushAdCampaign(adCampaign);

                        setState(() {
                          widget.party = widget.party.copyWith(isAdCampaignRunning: true);
                          FirestoreHelper.pushParty(widget.party);
                        });

                        Logx.ist(_TAG, 'ad campaign is now running');
                      } else {
                        // delete existing ad campaign
                        FirestoreHelper.pullAdCampaignByPartyId(widget.party.id).then((res){
                          if(res.docs.isNotEmpty){
                            DocumentSnapshot document = res.docs[0];
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            AdCampaign adCampaign = Fresh.freshAdCampaignMap(data, true);
                            FirestoreHelper.deleteAdCampaign(adCampaign.id);

                            setState(() {
                              widget.party = widget.party.copyWith(isAdCampaignRunning: false);
                              FirestoreHelper.pushParty(widget.party);

                              Logx.ist(_TAG, 'ad campaign is deleted');
                            });
                          } else {
                            setState(() {
                              widget.party = widget.party.copyWith(isAdCampaignRunning: false);
                              FirestoreHelper.pushParty(widget.party);

                              Logx.ist(_TAG, 'ad campaign could not be found');
                            });
                          }
                        });
                      }
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  const Text(
                    'challenge active : ',
                    style: TextStyle(fontSize: 17.0),
                  ), //Text
                  const SizedBox(width: 10), //SizedBox
                  Checkbox(
                    value: widget.party.isChallengeActive,
                    onChanged: (value) {
                      setState(() {
                        widget.party =
                            widget.party.copyWith(isChallengeActive: value);
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              const SizedBox(height: 24),
              FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    key: const ValueKey('override_challenge'),
                    decoration: InputDecoration(
                        errorStyle: const TextStyle(
                            color: Constants.errorColor, fontSize: 16.0),
                        hintText: 'please select override challenge',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    isEmpty: sOverrideChallenge == '',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: sOverrideChallenge,
                        isDense: true,
                        onChanged: (String? newValue) {
                          setState(() {
                            sOverrideChallenge = newValue!;

                            int sChallengeNum = 0;
                            for (Challenge ch in mChallenges) {
                              if (ch.title == sOverrideChallenge) {
                                sChallengeNum = ch.level;
                                break;
                              }
                            }
                            widget.party = widget.party
                                .copyWith(overrideChallengeNum: sChallengeNum);
                            state.didChange(newValue);
                          });
                        },
                        items: mChallengeNames.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'save',
                onClicked: () {
                  if (widget.party.blocServiceId.isEmpty) {
                    widget.party =
                        widget.party.copyWith(blocServiceId: _sBlocServiceId);
                  }

                  Party freshParty = Fresh.freshParty(widget.party);
                  FirestoreHelper.pushParty(freshParty);

                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'change week',
                onClicked: () {
                  int newStartTime =
                      widget.party.startTime + DateTimeUtils.millisecondsWeek;
                  int newEndTime =
                      widget.party.endTime + DateTimeUtils.millisecondsWeek;
                  int newGuestListEndTime = widget.party.guestListEndTime +
                      DateTimeUtils.millisecondsWeek;

                  Party freshParty = Fresh.freshParty(widget.party);
                  freshParty = freshParty.copyWith(
                      startTime: newStartTime,
                      endTime: newEndTime,
                      guestListEndTime: newGuestListEndTime,
                    shareCount: 0,
                    views: 0,
                  );
                  FirestoreHelper.pushParty(freshParty);

                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 24),
              ButtonWidget(
                text: 'duplicate party',
                onClicked: () {
                  Party duplicateParty = Dummy.getDummyParty(widget.party.blocServiceId);
                  duplicateParty = widget.party;
                  duplicateParty = duplicateParty.copyWith(id: StringUtils.getRandomString(28),
                    isActive: false, views: 0, createdAt: Timestamp.now().millisecondsSinceEpoch,
                  imageUrl: '', isAdCampaignRunning: false, imageUrls: [], shareCount: 0,
                  ticketUrl: '', storyImageUrl: '', showStoryImageUrl: false,);
                  FirestoreHelper.pushParty(duplicateParty);

                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (ctx) =>
                          PartyAddEditScreen(party: duplicateParty, task: 'edit')));
                },
              ),

              const SizedBox(height: 36),
              ButtonWidget(
                text: 'tix tier',
                onClicked: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) =>
                            ManageTixTiersScreen(partyId: widget.party.id, partyEndTime: widget.party.endTime,)),
                  );
                },
              ),

              const SizedBox(height: 36),
              DarkButtonWidget(
                text: 'delete',
                onClicked: () {
                  if (widget.party.imageUrls.length > 1) {
                    for (String imgUrl in widget.party.imageUrls) {
                      FirestorageHelper.deleteFile(imgUrl);
                    }
                  } else if (widget.party.imageUrl.isNotEmpty) {
                    FirestorageHelper.deleteFile(widget.party.imageUrl);
                  }

                  if (widget.party.storyImageUrl.isNotEmpty) {
                    FirestorageHelper.deleteFile(widget.party.storyImageUrl);
                  }

                  if(widget.party.isAdCampaignRunning){
                    FirestoreHelper.pullAdCampaignByPartyId(widget.party.id).then((res){
                      if(res.docs.isNotEmpty){
                        DocumentSnapshot document = res.docs[0];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        AdCampaign adCampaign = Fresh.freshAdCampaignMap(data, true);
                        FirestoreHelper.deleteAdCampaign(adCampaign.id);

                        setState(() {
                          widget.party = widget.party.copyWith(isAdCampaignRunning: false);
                          FirestoreHelper.pushParty(widget.party);

                          Logx.ist(_TAG, 'ad campaign is deleted');
                        });
                      } else {
                        setState(() {
                          widget.party = widget.party.copyWith(isAdCampaignRunning: false);
                          FirestoreHelper.pushParty(widget.party);

                          Logx.ist(_TAG, 'ad campaign could not be found');
                        });
                      }
                    });
                  }

                  FirestoreHelper.deleteParty(widget.party);
                  Logx.ist(_TAG, 'deleted party : ${widget.party.name}');
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 10),
            ],
          );
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      DateTime sDateTemp = DateTime(_sDate.year, _sDate.month, _sDate.day);

      setState(() {
        sDate = sDateTemp;
        _selectTime(context);
      });
    }
  }

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    setState(() {
      sTimeOfDay = pickedTime!;

      DateTime sDateTime = DateTime(sDate.year, sDate.month, sDate.day,
          sTimeOfDay.hour, sTimeOfDay.minute);

      if (_isStartDateBeingSet) {
        sStartDateTime = sDateTime;
        widget.party = widget.party
            .copyWith(startTime: sStartDateTime.millisecondsSinceEpoch);
      } else if (_isEndDateBeingSet) {
        sEndDateTime = sDateTime;
        widget.party =
            widget.party.copyWith(endTime: sEndDateTime.millisecondsSinceEpoch);
      } else if (_isGuestListDateBeingSet) {
        sEndGuestListDateTime = sDateTime;
        widget.party = widget.party.copyWith(
            guestListEndTime: sEndGuestListDateTime.millisecondsSinceEpoch);
      } else {
        Logx.em(_TAG, 'unhandled date time');
      }
    });
    return sTimeOfDay;
  }

  Widget dateTimeContainer(BuildContext context, String type) {
    sStartDateTime = DateTimeUtils.getDate(widget.party.startTime);
    sEndDateTime = DateTimeUtils.getDate(widget.party.endTime);
    sEndGuestListDateTime =
        DateTimeUtils.getDate(widget.party.guestListEndTime);

    DateTime dateTime;
    if (type == 'start') {
      dateTime = sStartDateTime;
    } else if (type == 'end') {
      dateTime = sEndDateTime;
    } else {
      dateTime = sEndGuestListDateTime;
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black38,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateTimeUtils.getFormattedDateString(
                  dateTime.millisecondsSinceEpoch),
              style: const TextStyle(
                fontSize: 18,
              )),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Constants.primary,
              shadowColor: Constants.shadowColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50), //////// HERE
            ),
            onPressed: () {
              if (type == 'start') {
                _isStartDateBeingSet = true;
                _isEndDateBeingSet = false;
                _isGuestListDateBeingSet = false;
              } else if (type == 'end') {
                _isStartDateBeingSet = false;
                _isEndDateBeingSet = true;
                _isGuestListDateBeingSet = false;
              } else {
                _isStartDateBeingSet = false;
                _isEndDateBeingSet = false;
                _isGuestListDateBeingSet = true;
              }
              _selectDate(context, dateTime);
            },
            child: Text(type == 'guestListEndTime'
                ? 'guestlist end time'
                : '$type date & time'),
          ),
        ],
      ),
    );
  }

  void _showDeleteExtraPhotosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text("delete extra details"),
          content: const Text(
              "would your like to delete extra photos?"),
          actions: [
            TextButton(
              child: const Text("yes"),
              onPressed: () {
                if (widget.party.imageUrls.length > 1) {
                  for (int i = 1; i < widget.party.imageUrls.length; i++) {
                    String imgUrl = widget.party.imageUrls[i];
                    FirestorageHelper.deleteFile(imgUrl);
                  }
                  Logx.ist(_TAG,
                      'party ${widget.party.imageUrls.length - 1} extra photos is deleted');
                }

                if (widget.party.storyImageUrl.isNotEmpty) {
                  FirestorageHelper.deleteFile(widget.party.storyImageUrl);
                  Logx.ist(_TAG, 'party story photo is deleted');
                }

                List<String> temp = [widget.party.imageUrl];
                widget.party =
                    widget.party.copyWith(storyImageUrl: '', imageUrls: temp);

                Navigator.of(ctx).pop();
              },
            ),

            TextButton(
              child: const Text("no"),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _photosListDialog() {
    return SingleChildScrollView(
      child: SizedBox(
        height: mq.height * 0.6,
        width: mq.width * 0.8,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: mImageUrls.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(mImageUrls[index],
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(50, 50),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orangeAccent,
                      child: InkWell(
                        splashColor: Colors.orange,
                        onTap: () {
                          int prevIndex = index--;
                          if (prevIndex >= 0) {
                            mImageUrls.swap(index, prevIndex);
                            widget.party =
                                widget.party.copyWith(imageUrls: mImageUrls);
                            FirestoreHelper.pushParty(widget.party);
                          } else {
                            Logx.ist(_TAG, 'photo is already the first');
                          }

                          setState(() {});
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.arrow_circle_up_outlined),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(50, 50),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orangeAccent,
                      child: InkWell(
                        splashColor: Colors.orange,
                        onTap: () {
                          int nextIndex = index++;
                          if (nextIndex <= mImageUrls.length - 1) {
                            mImageUrls.swap(index, nextIndex);
                            widget.party =
                                widget.party.copyWith(imageUrls: mImageUrls);
                            FirestoreHelper.pushParty(widget.party);
                          } else {
                            Logx.ist(_TAG, 'photo is already the last');
                          }

                          setState(() {
                            widget.party =
                                widget.party.copyWith(imageUrls: mImageUrls);
                            FirestoreHelper.pushParty(widget.party);
                          });
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.arrow_circle_down_outlined),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(50, 50),
                  child: ClipOval(
                    child: Material(
                      color: Colors.redAccent,
                      child: InkWell(
                        splashColor: Colors.red,
                        onTap: () {
                          FirestorageHelper.deleteFile(mImageUrls[index]);
                          mImageUrls.removeAt(index);

                          if (index == 0) {
                            String imgUrl = mImageUrls[0];
                            widget.party = widget.party.copyWith(
                                imageUrl: imgUrl, imageUrls: mImageUrls);
                          } else {
                            widget.party =
                                widget.party.copyWith(imageUrls: mImageUrls);
                          }

                          FirestoreHelper.pushParty(widget.party);

                          setState(() {});
                          Navigator.of(context).pop();
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.delete_forever),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
