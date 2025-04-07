import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../account/components/user_avatar.dart';
import '../account/components/side_menu.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _usernameController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _websiteController = TextEditingController();
  String? _userName;
  String? _avatarUrl;
  bool _isLoading = false;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullnameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<String?> _getSignedAvatarUrl(String? avatarPath) async {
    if (avatarPath == null || avatarPath.isEmpty) return null;

    try {
      final response = await _supabase.storage
          .from('avatars')
          .createSignedUrl(avatarPath, 3600);
      return response;
    } catch (e) {
      debugPrint("Error getting signed URL: $e");
      return null;
    }
  }

  Future<void> _fetchProfile() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('profiles')
            .select('avatar_url, full_name, username, website')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          final avatarUrl = await _getSignedAvatarUrl(response['avatar_url']);

          if (!mounted) return;

          setState(() {
            _avatarUrl = avatarUrl;
            _userName = response['full_name'] ?? 'No Name';
            _usernameController.text = response['username'] ?? '';
            _fullnameController.text = response['full_name'] ?? '';
            _websiteController.text = response['website'] ?? '';
          });
        }
      }
    } catch (error) {
      debugPrint("Error fetching profile: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadAvatar() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      setState(() => _isLoading = true);

      final file = File(pickedFile.path);
      final fileExt = pickedFile.path.split('.').last;
      final fileName = '${user.id}.$fileExt';

      await _supabase.storage
          .from('avatars')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      await _supabase
          .from('profiles')
          .update({'avatar_url': fileName})
          .eq('id', user.id);

      setState(() => _avatarUrl = imageUrl);
    } catch (error) {
      debugPrint("Error al subir avatar: $error");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${error.toString()}')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    final username = _usernameController.text.trim();
    final fullName = _fullnameController.text.trim();
    
    if (username.isEmpty || fullName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username and full name are required')),
        );
      }
      return;
    }

    try {
      setState(() => _isLoading = true);
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('profiles')
          .update({
            'username': username,
            'full_name': fullName,
            'website': _websiteController.text.trim(),
          })
          .eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } catch (error) {
      debugPrint("Error updating profile: $error");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openEndDrawer() => _scaffoldKey.currentState?.openEndDrawer();

  void _navigateToTodo(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/select');
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        actions: [UserAvatar(avatarUrl: _avatarUrl, onPressed: _openEndDrawer)],
      ),
      endDrawer: SideMenu(
        avatarUrl: _avatarUrl,
        userName: _userName,
        userEmail: user?.email,
        onAccountPressed: () => _navigateToTodo(context),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _uploadAvatar,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            _avatarUrl != null
                                ? NetworkImage(_avatarUrl!)
                                : null,
                        child:
                            _avatarUrl == null
                                ? const Icon(Icons.person, size: 60)
                                : null,
                      ),
                    ),
                    TextButton(
                      onPressed: _uploadAvatar,
                      child: const Text('Cambiar foto de perfil'),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      initialValue: user?.email ?? 'No disponible',
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        border: OutlineInputBorder(),
                        filled: true,                        
                      ),
                      enabled: false, // Esto hace que el campo no sea editable
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de usuario',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _fullnameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre completo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Sitio web',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('GUARDAR CAMBIOS'),
                    ),
                  ],
                ),
              ),
    );
  }
}
