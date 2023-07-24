import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../db/entity/ad.dart';
import '../../../db/entity/config.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/logx.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/listview_block.dart';
import '../../../widgets/ui/loading_widget.dart';
import 'config_add_edit_screen.dart';

class ManageConfigsScreen extends StatelessWidget {
  static const String _TAG = 'ManageConfigsScreen';

  String blocServiceId;

  ManageConfigsScreen({Key? key,
    required this.blocServiceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: AppBarTitle(title:'manage configs'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (ctx) => ConfigAddEditScreen(
                  config: Dummy.getDummyConfig(blocServiceId),
                  task: 'add',
                )),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'add config',
        elevation: 5,
        splashColor: Colors.grey,
        child: const Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          _buildConfigs(context),
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }

  _buildConfigs(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirestoreHelper.getConfigs(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          List<Config> _configs = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            DocumentSnapshot document = snapshot.data!.docs[i];
            Map<String, dynamic> map = document.data()! as Map<String, dynamic>;
            final Config _config = Fresh.freshConfigMap(map, false);
            _configs.add(_config);

            if (i == snapshot.data!.docs.length - 1) {
              return _showConfigs(context, _configs);
            }
          }
          Logx.i(_TAG, 'loading ads...');
          return const LoadingWidget();
        });
  }

  _showConfigs(BuildContext context, List<Config> configs) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
          itemCount: configs.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (ctx, index) {
            return GestureDetector(
                child: ListViewBlock(
                  title: configs[index].name,
                ),
                onTap: () {
                  Config config = configs[index];

                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (ctx) => ConfigAddEditScreen(
                          config: config,
                          task: 'edit',
                        )),
                  );
                });
          }),
    );
  }
}
