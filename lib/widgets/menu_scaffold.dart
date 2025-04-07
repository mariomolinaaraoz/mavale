import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../components/side_menu/side_menu.dart';
import '../components/side_menu/user_avatar.dart';

class MenuScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final Widget? bottomNavigationBar;
  final List<Widget>? actions;

  const MenuScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottomNavigationBar,
    this.actions,
  });

  @override
  State<MenuScaffold> createState() => _MenuScaffoldState();
}

class _MenuScaffoldState extends State<MenuScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _userName;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final response =
          await supabase
              .from('profiles')
              .select('avatar_url, full_name')
              .eq('id', user.id)
              .single();
      final signedUrl = await _getSignedUrl(response['avatar_url']);
      if (mounted) {
        setState(() {
          _avatarUrl = signedUrl;
          _userName = response['full_name'];
        });
      }
    }
  }

  Future<String?> _getSignedUrl(String? avatarUrl) async {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    try {
      return await supabase.storage
          .from('avatars')
          .createSignedUrl(avatarUrl, 3600);
    } catch (error) {
      debugPrint("Error al obtener la URL firmada: $error");
      return null;
    }
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor),
        ),
        actions: [
          UserAvatar(avatarUrl: _avatarUrl, onPressed: _openEndDrawer),
          ...?widget.actions,
        ],
      ),
      endDrawer: SideMenu(
        avatarUrl: _avatarUrl,
        userName: _userName,
        userEmail: supabase.auth.currentUser?.email,
        onAccountPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/account');
        },
      ),
      body: widget.body,
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}
