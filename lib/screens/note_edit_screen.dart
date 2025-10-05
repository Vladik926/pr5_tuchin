import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? note;

  const NoteEditScreen({Key? key, this.note}) : super(key: key);

  @override
  _NoteEditScreenState createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isEdited = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    
    _titleController.addListener(_checkChanges);
    _contentController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final originalTitle = widget.note?.title ?? '';
    final originalContent = widget.note?.content ?? '';
    
    setState(() {
      _isEdited = _titleController.text != originalTitle || 
                 _contentController.text != originalContent;
    });
  }

  void _saveNote() {
    if (_titleController.text.trim().isEmpty && 
        _contentController.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }

    final note = widget.note != null
        ? Note(
            id: widget.note!.id,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            createdAt: widget.note!.createdAt,
            updatedAt: DateTime.now(),
            color: widget.note!.color,
          )
        : Note.create(
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
          );

    Navigator.pop(context, note);
  }

  void _deleteNote() {
    if (widget.note != null) {
      Navigator.pop(context, 'delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'Новая заметка' : 'Редактировать',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        actions: [
          if (_isEdited)
            IconButton(
              icon: Icon(Icons.save, color: Colors.white),
              onPressed: _saveNote,
            ),
          if (widget.note != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: _deleteNote,
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Заголовок',
                hintStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                ),
              ),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: null,
            ),
            Divider(color: Colors.grey[300]),
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Начните писать здесь...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                style: TextStyle(fontSize: 16),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveNote,
        child: Icon(Icons.save),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}