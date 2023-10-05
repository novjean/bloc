
import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/genre.dart';
import '../../db/entity/history_music.dart';
import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class LoungeMemberItem extends StatefulWidget{
  User user;
  String loungeId;
  bool isMember;
  bool isUserLoungePresent;
  bool isExited;

  bool showHistory;
  List<Genre> genres;

  LoungeMemberItem({Key? key, required this.user, required this.loungeId,
    required this.isMember, required this.isUserLoungePresent,
    required this.isExited, required this.showHistory, required this.genres
  }) : super(key: key);

  @override
  State<LoungeMemberItem> createState() => _LoungeMemberItemState();
}

class _LoungeMemberItemState extends State<LoungeMemberItem> {
  static const String _TAG = 'LoungeMemberItem';

  var _isHistoryLoading = true;

  List<HistoryMusic> mHistoryMusics = [];
  int mTotalEventsCount = 0;

  String genrePercent = '';

  @override
  void initState() {
    if(widget.showHistory){
      FirestoreHelper.pullHistoryMusicByUser(widget.user.id).then((res) {
        if(res.docs.isNotEmpty){
          for (int i = 0; i < res.docs.length; i++) {
            DocumentSnapshot document = res.docs[i];
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            final HistoryMusic historyMusic = Fresh.freshHistoryMusicMap(data, false);
            mHistoryMusics.add(historyMusic);
            mTotalEventsCount += historyMusic.count;
          }

          mHistoryMusics.sort((a, b) => a.genre.compareTo(b.genre));
          mHistoryMusics.reversed;

          List<HistoryMusic> finalList = [mHistoryMusics.first];

          HistoryMusic prev = mHistoryMusics.first;

          for(int i=1;i<mHistoryMusics.length;i++){
            HistoryMusic curr = mHistoryMusics[i];

            if(prev.genre == curr.genre){
              int newCount = prev.count + curr.count;
              prev = prev.copyWith(count: newCount);
              finalList.last = prev;

              FirestoreHelper.deleteHistoryMusic(curr.id);
            } else {
              prev = curr;
              finalList.add(prev);
            }
          }

          finalList.sort((a, b) => b.count.compareTo(a.count));

          for(int i=0;i<finalList.length; i++){
            HistoryMusic hm = finalList[i];
            genrePercent += '${hm.count} ${hm.genre} | ';

            FirestoreHelper.pushHistoryMusic(hm);
          }

          genrePercent += 'total: $mTotalEventsCount';

          if(mounted){
            setState(() {
              _isHistoryLoading = false;
            });
          } else {
            Logx.em(_TAG, 'not mounted');
          }
        } else {
          setState(() {
            _isHistoryLoading = false;
          });
        }
      });
    } else {
      setState(() {
        _isHistoryLoading = false;
      });
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isHistoryLoading? const LoadingWidget() : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: widget.user.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading:
                  widget.user.imageUrl.isNotEmpty?
                  FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(widget.user.imageUrl),
                    fit: BoxFit.cover,):
                  const CircleAvatar(
                    radius: 20.0,
                    backgroundImage: AssetImage('assets/icons/logo.png'),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          text: '${widget.user.name} ',
                          style: const TextStyle(
                              fontFamily: Constants.fontDefault,
                              color: Colors.black,
                              overflow: TextOverflow.ellipsis,
                              fontSize: 16,
                              letterSpacing: 1,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text('+${widget.user.phoneNumber}', style: TextStyle(fontSize: 14),)
                    ],
                  ),

                  subtitle: widget.showHistory ?
                      Text(genrePercent)
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children:[
                      Text(widget.user.gender),
                      Text(widget.user.isAppUser?'app':'web'),
                      Text('level ${widget.user.challengeLevel}'),
                      Text(widget.isExited?'exit':'NaN')
                    ]
                  ),
                  trailing: Checkbox(
                    value: widget.isMember,
                    onChanged: (value) {
                      if(widget.isUserLoungePresent){
                        if(value!){
                          FirestoreHelper.pullUserLounge(widget.user.id, widget.loungeId).then((res) {
                            if(res.docs.isNotEmpty){
                              DocumentSnapshot document = res.docs[0];
                              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                              UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);
                              userLounge = userLounge.copyWith(isAccepted: true, userFcmToken: widget.user.fcmToken);
                              FirestoreHelper.pushUserLounge(userLounge);
                              Logx.ist(_TAG, '${widget.user.name} ${widget.user.surname} is a new member');
                            }
                          });
                        } else {
                          deleteUserLounge();
                        }
                      } else {
                        if(value!){
                          UserLounge userLounge = Dummy.getDummyUserLounge();
                          userLounge = userLounge.copyWith(loungeId : widget.loungeId,
                              userId: widget.user.id, userFcmToken: widget.user.fcmToken);
                          FirestoreHelper.pushUserLounge(userLounge);

                          Logx.ist(_TAG, '${widget.user.name} ${widget.user.surname} is a new member');
                        } else {
                          deleteUserLounge();
                        }
                      }
                      setState(() {
                        widget.isMember = !widget.isMember;
                      });
                    },
                  ),

                  // leadingAndTrailingTextStyle: TextStyle(
                  //     color: Colors.black, fontFamily: 'BalsamiqSans_Regular'),
                  // trailing: Text(time, style: TextStyle(fontSize: 10),),
                )),
          ),
        ),
      ),
    );
  }

  void deleteUserLounge() {
    FirestoreHelper.pullUserLounge(widget.user.id, widget.loungeId).then((res) {
      if(res.docs.isNotEmpty){
        DocumentSnapshot document = res.docs[0];
        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
        UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);

        FirestoreHelper.deleteUserLounge(userLounge.id);
        Logx.ist(_TAG, '${widget.user.name} ${widget.user.surname} is removed from the lounge');
      } else {
        Logx.i(_TAG, 'user lounge not found. so nothing to delete');
      }
    });
  }
}