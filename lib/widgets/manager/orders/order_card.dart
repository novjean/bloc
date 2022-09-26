import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget{
  String title;
  String collapsed;
  String expanded;
  String imageUrl;

  OrderCard({required this.title, required this.collapsed,required this.expanded, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // GestureDetector(
              //   onTap: () => controller.toggle(),
              //   child: Image.network(urlImage),
              // ),
              ScrollOnExpand(
                child: ExpandablePanel(
                  // controller: controller,
                  theme: ExpandableThemeData(
                    expandIcon: Icons.arrow_downward,
                    collapseIcon: Icons.arrow_upward,
                    tapBodyToCollapse: true,
                    tapBodyToExpand: true,
                  ),
                  header: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  collapsed: Text(
                    collapsed,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    softWrap: true,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  expanded: Text(
                    expanded,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  builder: (_, collapsed, expanded) => Padding(
                    padding: EdgeInsets.all(10).copyWith(top: 0),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}