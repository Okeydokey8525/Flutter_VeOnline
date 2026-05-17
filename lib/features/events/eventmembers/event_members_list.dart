import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class EventMembersList extends StatefulWidget {
  final int eventId;
  const EventMembersList({super.key, required this.eventId});

  @override
  State<EventMembersList> createState() => _EventMembersListState();
}

class _EventMembersListState extends State<EventMembersList> {
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final box = GetStorage();
      final token = box.read('accessToken') as String?;

      if (token == null || token.isEmpty) {
        setState(() {
          isLoading = false;
          error = 'Bạn cần đăng nhập để xem người tham gia.';
        });
        return;
      }

      final url = Uri.parse('http://10.0.2.2:5054/api/events/${widget.eventId}/members');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded is List ? decoded : <dynamic>[])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        setState(() {
          members = list;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          error = 'Không thể tải danh sách (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        error = 'Lỗi tải danh sách: $e';
      });
    }
  }

  String _formatDate(dynamic rawDate) {
    final value = rawDate?.toString() ?? '';
    if (value.isEmpty) return 'N/A';
    return value.length >= 16 ? value.substring(0, 16) : value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Người tham gia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: fetchMembers,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red))
        else if (members.isEmpty)
          const Text('Chưa có người tham gia nào.')
        else
          Column(
            children: members.map((m) {
              final email = (m['email'] ?? m['username'] ?? 'N/A').toString();
              final date = _formatDate(m['registrationDate']);
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(email),
                  subtitle: Text('Đăng ký: $date'),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
