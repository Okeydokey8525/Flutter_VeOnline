import 'package:flutter/material.dart';
import 'package:event_ticket_app/core/theme/app_tokens.dart';
import 'package:get_storage/get_storage.dart';

import '../model/event.dart';
import '../services/event_service.dart';
import 'event_create_screen.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late Future<List<Event>> _futureEvents;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() => setState(() => _futureEvents = EventService.getEvents());

  @override
  Widget build(BuildContext context) {
    final userRole = (GetStorage().read('role') ?? 'User').toString().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sự kiện'),
        actions: [
          if (userRole == 'organizer')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final created = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EventCreateScreen()));
                if (created == true) _loadEvents();
              },
            ),
        ],
      ),
      body: FutureBuilder<List<Event>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _stateBox(Icons.error_outline, 'Không thể tải danh sách sự kiện', '${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _stateBox(Icons.event_busy, 'Chưa có sự kiện nào', 'Hãy quay lại sau hoặc tạo sự kiện mới.');
          }

          final events = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final e = events[index];
              final date = e.startTime.toString().split(' ').first;
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  leading: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: AppColors.infoSoft, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.event, color: Color(0xFF0D6EFD)),
                  ),
                  title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('📍 ${e.location}\n$date'),
                  isThreeLine: true,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.infoSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text('Chi tiết', style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.w600)),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EventDetailScreen(eventId: e.id!, userRole: userRole)),
                  ).then((_) => _loadEvents()),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _stateBox(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
