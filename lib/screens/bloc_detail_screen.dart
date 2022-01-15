import 'package:bloc/widgets/app_drawer.dart';
import 'package:flutter/material.dart';

class BlocDetailScreen extends StatelessWidget {
  static const routeName = '/bloc-detail';

  const BlocDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blocName = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(blocName),
      ),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.of(context).pushNamed(
          //   NewBlocScreen.routeName,
          //   arguments: cityName,
          // );
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
          size: 29,
        ),
        backgroundColor: Theme.of(context).primaryColor,
        tooltip: 'New Bloc',
        elevation: 5,
        splashColor: Colors.grey,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(child: Text('Bloc detail loading...'),),

      // StreamBuilder(
      //   stream: FirebaseFirestore.instance.collection('blocs').snapshots(),
      //   builder: (ctx, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     }
      //     final blocDocs = snapshot.data.docs;
      //
      //     return GridView.builder(
      //       // const keyword can be used so that it does not rebuild when the build method is called
      //       // useful for performance improvement
      //       padding: const EdgeInsets.all(10.0),
      //       itemCount: blocDocs.length,
      //       // grid delegate describes how many grids should be there
      //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      //         crossAxisCount: 2,
      //         childAspectRatio: 3 / 2,
      //         crossAxisSpacing: 10,
      //         mainAxisSpacing: 10,
      //       ),
      //       // item builder defines how the grid should look
      //       itemBuilder: (ctx, index) => BlocItem(
      //         blocDocs[index].id,
      //         blocDocs[index].data()['addressLine1'],
      //         blocDocs[index].data()['imageUrl'],
      //         key: ValueKey(blocDocs[index].id),
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
