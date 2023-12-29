import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../db/entity/bloc.dart';

class OwnerBlocItem extends StatelessWidget{
  static const String _TAG = 'OwnerBlocItem';

  Bloc bloc;

  OwnerBlocItem({Key? key, required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: bloc.id,
          child: Card(
            elevation: 1,
            color: Constants.lightPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
                padding: const EdgeInsets.only(top: 2.0, left: 5, right: 5),
                child: ListTile(
                  leading: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/icons/logo.png'),
                    image: NetworkImage(bloc.imageUrls[0]),
                    fit: BoxFit.cover,),
                  title: RichText(
                    text: TextSpan(
                      text: '${bloc.name} ',
                      style: const TextStyle(
                          fontFamily: Constants.fontDefault,
                          color: Colors.black,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${bloc.orderPriority}'),
                      // Text('${bloc.likers.length + bloc.initLikes} 🖤'),
                      // Text('${bloc.downloadCount} 💾'),
                    ],
                  ),
                  trailing: RichText(
                    text: TextSpan(
                      text:
                      bloc.isActive ? '✅' : '☑️',
                      style: const TextStyle(
                        fontFamily: Constants.fontDefault,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

}