import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../db/entity/user.dart';
import '../../helpers/dummy.dart';
import '../../helpers/fresh.dart';
import '../../utils/constants.dart';
import '../../utils/logx.dart';

class LoungeMemberItem extends StatefulWidget{
  static const String _TAG = 'LoungeMemberItem';

  User user;
  String loungeId;
  bool isMember;
  bool isUserLoungePresent;
  bool isExited;

  LoungeMemberItem({Key? key, required this.user, required this.loungeId,
    required this.isMember, required this.isUserLoungePresent, required this.isExited}) : super(key: key);

  @override
  State<LoungeMemberItem> createState() => _LoungeMemberItemState();
}

class _LoungeMemberItemState extends State<LoungeMemberItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
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

                  subtitle: Row(
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

                              userLounge = userLounge.copyWith(isAccepted: true);
                              FirestoreHelper.pushUserLounge(userLounge);
                              Logx.ist(LoungeMemberItem._TAG, '${widget.user.name} ${widget.user.surname} is a new member');
                            }
                          });
                        } else {
                          deleteUserLounge();
                        }
                      } else {
                        if(value!){
                          UserLounge userLounge = Dummy.getDummyUserLounge();
                          userLounge = userLounge.copyWith(loungeId : widget.loungeId, userId: widget.user.id);
                          FirestoreHelper.pushUserLounge(userLounge);

                          Logx.ist(LoungeMemberItem._TAG, '${widget.user.name} ${widget.user.surname} is a new member');
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
        Logx.ist(LoungeMemberItem._TAG, '${widget.user.name} ${widget.user.surname} is removed from the lounge');
      } else {
        Logx.i(LoungeMemberItem._TAG, 'user lounge not found. so nothing to delete');
      }
    });
  }
}