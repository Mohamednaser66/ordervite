import 'package:flutter_maps/models/conversation_model.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback? onTap;

  const ConversationCard({
    Key? key,
    required this.conversation,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipOval(
        child: Image.network(
          conversation.user?.imageUrl ??
              'https://s3.amazonaws.com/37assets/svn/765-default-avatar.png',
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            conversation.user?.name ?? "",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18.sp,
            ),
          ),
          Text(
            timeago.format(
              DateTime.parse(
                conversation.messages?.last.createdAt??'',
              ),
            ),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
      subtitle: Text(
        conversation.messages?.last.body ?? "",
      ),
    );
  }
}