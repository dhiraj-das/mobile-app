import 'package:corona_trace/network/APIRepository.dart';
import 'package:corona_trace/network/ResponseNotifications.dart';
import 'package:corona_trace/ui/notifications/CTLoader.dart';
import 'package:corona_trace/ui/notifications/CTNotificationItem.dart';
import 'package:corona_trace/ui/notifications/CTNotificationMapDetail.dart';
import 'package:corona_trace/ui/notifications/blocs/CTNotificationsBloc.dart';
import 'package:flutter/material.dart';

class CTNotificationsListWidget extends StatefulWidget {
  @override
  _CTNotificationsListWidgetState createState() =>
      _CTNotificationsListWidgetState();
}

class _CTNotificationsListWidgetState extends State<CTNotificationsListWidget> {
  ScrollController _controller;
  final _notificationsBloc =
      CTNotificationsBloc(); // In production, a provider should be used instead of initializing here

  @override
  void initState() {
    super.initState();
    _notificationsBloc.fetchNotifications();
    _controller = ScrollController()..addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_controller.position.pixels == _controller.position.maxScrollExtent) {
      print("load more called");
      _notificationsBloc.loadMore();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _notificationsBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ResponseNotificationItem>>(
      stream: _notificationsBloc.notificationsStream,
      builder: (context, snapshot) {
        print(snapshot.data);
        return SingleChildScrollView(
          controller: _controller,
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey,
              );
            },
            itemBuilder: (context, index) {
              var item = snapshot.data[index];
              return InkWell(
                child: CTNotificationItem(
                    crossedPaths: index % 2 == 0, notification: item),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return CTNotificationMapDetail(
                        crossedPaths:  index % 2 == 0, notification: item);
                  }));
                },
              );
            },
            itemCount: snapshot.data?.length ?? 0,
          ),
        );
      },
    );
  }
}
