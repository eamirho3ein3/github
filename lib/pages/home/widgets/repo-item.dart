import 'package:flutter/material.dart';
import 'package:github/models/repo.dart';

class RipoItem extends StatelessWidget {
  final Repo item;
  RipoItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), color: Colors.grey[400]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // title
          Text(
            item.name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                // create date
                Expanded(child: Text(item.createdAt)),

                // private icon
                item.isPrivate
                    ? Icon(
                        Icons.lock,
                        size: 20,
                      )
                    : Container()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
