import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../models/project_model.dart';
import '../../providers/location_provider.dart';
import '../../services/project_service.dart';
import 'map_selection.dart';


class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  _AddProjectScreenState createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectsService = ProjectsService();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _locationArController = TextEditingController();

  // Form data
  ProjectModel _project = ProjectModel.empty();
  File? _coverImage;
  File? _logoImage;
  List<File> _photosList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Project'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _handleSubmit,
            icon: _isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white),
            )
                : Icon(Icons.save, color: Colors.white),
            label: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.all(16),
            children: [
              _buildSection(
                title: 'Basic Information',
                children: [
                  _buildImagePicker(
                    title: 'Project Cover Image',
                    image: _coverImage,
                    onPick: (file) => setState(() => _coverImage = file),
                  ),
                  SizedBox(height: 16),
                  _buildImagePicker(
                    title: 'Project Logo',
                    image: _logoImage,
                    onPick: (file) => setState(() => _logoImage = file),
                    isCircular: true,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Project Name (English)',
                    onSaved: (value) => _project = _project.copyWith(
                      projectName: value,
                    ),
                    validator: (value) =>
                    value?.isEmpty == true ? 'Required field' : null,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Project Name (Arabic)',
                    textDirection: TextDirection.rtl,
                    onSaved: (value) => _project = _project.copyWith(
                      projectNameAr: value,
                    ),
                    validator: (value) =>
                    value?.isEmpty == true ? 'Required field' : null,
                  ),
                ],
              ),
              _buildSection(
                title: 'Project Details',
                children: [
                  _buildDropdownField(
                    label: 'Project Type',
                    items: ['Residential', 'Commercial', 'Mixed Use'],
                    onChanged: (value) => setState(() => _project = _project.copyWith(
                      projectType: value,
                    )),
                    value: _project.projectType,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Project Type (Arabic)',
                    textDirection: TextDirection.rtl,
                    onSaved: (value) => _project = _project.copyWith(
                      projectTypeAr: value,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Address (English)',
                    onSaved: (value) => _project = _project.copyWith(
                      projectAddress: value,
                    ),
                    validator: (value) =>
                    value?.isEmpty == true ? 'Required field' : null,
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Address (Arabic)',
                    textDirection: TextDirection.rtl,
                    onSaved: (value) => _project = _project.copyWith(
                      projectAddressAr: value,
                    ),
                  ),
                ],
              ),
              _buildLocationSection(),//location picker
              _buildSection(
                title: 'Project Status',
                children: [
                  _buildTextField(
                    label: 'Latest Status (English)',
                    onSaved: (value) => _project = _project.copyWith(
                      projectLatestStatus: value,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Latest Status (Arabic)',
                    textDirection: TextDirection.rtl,
                    onSaved: (value) => _project = _project.copyWith(
                      projectLatestStatusAr: value,
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'Units Information',
                children: [
                  _buildTextField(
                    label: 'Units Types (English)',
                    onSaved: (value) => _project = _project.copyWith(
                      projectUnitsTypes: value,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Units Types (Arabic)',
                    textDirection: TextDirection.rtl,
                    onSaved: (value) => _project = _project.copyWith(
                      projectUnitsTypesAr: value,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Spaces (English)',
                    onSaved: (value) => _project = _project.copyWith(
                      projectSpaces: value,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Spaces (Arabic)',
                    textDirection: TextDirection.rtl,
                    onSaved: (value) => _project = _project.copyWith(
                      projectSpacesAr: value,
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'Description',
                children: [
                  _buildTextField(
                    label: 'Description (English)',
                    maxLines: 5,
                    onSaved: (value) => _project = _project.copyWith(
                      projectDesc: value,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Description (Arabic)',
                    textDirection: TextDirection.rtl,
                    maxLines: 5,
                    onSaved: (value) => _project = _project.copyWith(
                      projectDescAr: value,
                    ),
                  ),
                ],
              ),
              _buildSection(
                title: 'Media',
                children: [
                  _buildTextField(
                    label: 'Video URL',
                    onSaved: (value) => _project = _project.copyWith(
                      projectVideo: value,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildMultiImagePicker(
                    title: 'Project Photos',
                    images: _photosList,
                    onPick: (files) => setState(() => _photosList = files),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        ...children,
        SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    TextDirection? textDirection,
    int maxLines = 1,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      textDirection: textDirection,
      maxLines: maxLines,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? value,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Add these functions to the _AddProjectScreenState class

  Widget _buildImagePicker({
    required String title,
    required File? image,
    required Function(File?) onPick,
    bool isCircular = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        Stack(
          children: [
            InkWell(
              onTap: () => _pickImage(onPick),
              child: Container(
                height: isCircular ? 150 : 200,
                width: isCircular ? 150 : double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(isCircular ? 75 : 8),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: image != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(isCircular ? 75 : 8),
                  child: Image.file(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCircular
                          ? Icons.add_photo_alternate_rounded
                          : Icons.add_photo_alternate,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Click to upload',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      isCircular ? 'Square image recommended' : 'Landscape image recommended',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (image != null)
              Positioned(
                top: 8,
                right: 8,
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () => _showImageOptions(image, onPick),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildMultiImagePicker({
    required String title,
    required List<File> images,
    required Function(List<File>) onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => _pickMultipleImages(images, onPick),
              icon: Icon(Icons.add_photo_alternate),
              label: Text('Add Photos'),
            ),
          ],
        ),
        SizedBox(height: 8),
        if (images.isEmpty)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_library,
                  size: 48,
                  color: Colors.grey[600],
                ),
                SizedBox(height: 8),
                Text(
                  'No photos added yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Add up to 10 photos',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 200,
                child: ReorderableListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final File item = images.removeAt(oldIndex);
                      images.insert(newIndex, item);
                      onPick(images);
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      key: ValueKey(images[index].path),
                      width: 200,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              images[index],
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () => _removeImage(index, images, onPick),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Photo ${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (images.length > 1)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Drag to reorder photos',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return _buildSection(
          title: 'Location Information',
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _locationController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Location (English)',
                            prefixIcon: const Icon(Icons.location_on),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.map),
                              onPressed: () => _selectLocation(),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                          value?.isEmpty == true ? 'Please select a location' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _locationArController,
                          readOnly: true,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            labelText: 'الموقع',
                            prefixIcon: const Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (locationProvider.projectLocation != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Coordinates:',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Lat: ${locationProvider.projectLocation!.location.latitude.toStringAsFixed(6)}\n'
                                      'Lng: ${locationProvider.projectLocation!.location.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectLocation() async {
    try {
      final result = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (context) => MapSelectionScreen(
            title: 'Select Project Location',
            initialLocation: context.read<LocationProvider>().projectLocation?.location,
          ),
        ),
      );

      if (result != null && mounted) {
        final location = result['location'] as LatLng;
        final address = result['address'] as String;
        final addressAr = result['addressAr'] as String?;

        setState(() {
          _locationController.text = address;
          _locationArController.text = addressAr ?? '';
        });

        context.read<LocationProvider>().setProjectLocation(
          LocationData(
            location: location,
            address: address,
            addressAr: addressAr,
          ),
        );

        // Update project model
        _project = _project.copyWith(
          projectLocation: '${location.latitude},${location.longitude}',
          projectAddress: address,
          projectAddressAr: addressAr,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error selecting location: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _locationArController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(Function(File?) onPick) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a photo'),
                onTap: () async {
                  Navigator.pop(context, await picker.pickImage(
                    source: ImageSource.camera,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  ));
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () async {
                  Navigator.pop(context, await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 1920,
                    maxHeight: 1080,
                    imageQuality: 85,
                  ));
                },
              ),
            ],
          ),
        );
      },
    );

    if (image != null) {
      onPick(File(image.path));
    }
  }

  Future<void> _pickMultipleImages(List<File> currentImages, Function(List<File>) onPick) async {
    if (currentImages.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum 10 photos allowed')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      final newImages = [...currentImages];
      for (var image in images) {
        if (newImages.length < 10) {
          newImages.add(File(image.path));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Maximum 10 photos allowed')),
          );
          break;
        }
      }
      onPick(newImages);
    }
  }

  void _removeImage(int index, List<File> images, Function(List<File>) onPick) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Photo'),
          content: Text('Are you sure you want to remove this photo?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                final newImages = [...images];
                newImages.removeAt(index);
                onPick(newImages);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImageOptions(File image, Function(File?) onPick) async {
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Replace image'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(onPick);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Remove image'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Remove Image'),
                        content: Text('Are you sure you want to remove this image?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: Text(
                              'Remove',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onPick(null);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      _formKey.currentState!.save();

      // Upload images
      final storage = FirebaseStorage.instance;
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      String? coverUrl;
      if (_coverImage != null) {
        final coverRef = storage.ref('projects/covers/$timestamp.jpg');
        await coverRef.putFile(_coverImage!);
        coverUrl = await coverRef.getDownloadURL();
      }

      String? logoUrl;
      if (_logoImage != null) {
        final logoRef = storage.ref('projects/logos/$timestamp.jpg');
        await logoRef.putFile(_logoImage!);
        logoUrl = await logoRef.getDownloadURL();
      }

      List<String> photoUrls = [];
      for (var i = 0; i < _photosList.length; i++) {
        final photoRef = storage.ref('projects/photos/$timestamp-$i.jpg');
        await photoRef.putFile(_photosList[i]);
        final url = await photoRef.getDownloadURL();
        photoUrls.add(url);
      }

      final newProject = _project.copyWith(
        projectCover: coverUrl,
        projectLogo: logoUrl,
        projectPhotosList: photoUrls,
        createdAt: DateTime.now(),
        createdBy: 'Ramy888',
        isActive: true,
      );

      await _projectsService.addProject(newProject);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Project added successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

}