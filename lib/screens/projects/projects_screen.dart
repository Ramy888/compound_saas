import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/project_model.dart';
import '../../providers/project_provider.dart';
import '../../services/project_service.dart';
import '../../widgets/projects/project_list.dart';
import 'add_project_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProjectsService _projectsService = ProjectsService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Projects'),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Active Projects'),
                Tab(text: 'Removed Projects'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              StreamBuilder<List<ProjectModel>>(
                stream: projectProvider.getActiveProjects(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ProjectListView(
                    projects: snapshot.data!,
                    onProjectTap: _handleProjectTap,
                    onProjectRemove:
                        (project) => _handleProjectRemove(
                          context,
                          project,
                          projectProvider,
                        ),
                  );
                },
              ),
              StreamBuilder<List<ProjectModel>>(
                stream: projectProvider.getRemovedProjects(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ProjectListView(
                    projects: snapshot.data!,
                    onProjectTap: _handleProjectTap,
                    onProjectRestore:
                        (project) => _handleProjectRestore(
                          context,
                          project,
                          projectProvider,
                        ),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _navigateToAddProject,
            label: Text('Add Project'),
            icon: Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _navigateToAddProject() async {
    await Navigator.pushNamed(context, '/add_project');
  }

  void _handleProjectTap(ProjectModel project) {
    // TODO: Navigate to project details screen
  }

  Future<void> _handleProjectRemove(
    BuildContext context,
    ProjectModel project,
    ProjectProvider provider,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => _buildRemovalDialog(),
    );

    if (reason != null && reason.isNotEmpty) {
      await provider.removeProject(project.projectId!, reason);
      if (provider.status == ProjectStatus.success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Project removed successfully')));
      } else if (provider.status == ProjectStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${provider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleProjectRestore(
    BuildContext context,
    ProjectModel project,
    ProjectProvider provider,
  ) async {
    await provider.restoreProject(project.projectId!);
    if (provider.status == ProjectStatus.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Project restored successfully')));
    } else if (provider.status == ProjectStatus.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRemovalDialog() {
    final controller = TextEditingController();

    return AlertDialog(
      title: Text('Remove Project'),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Reason for removal',
          hintText: 'Enter the reason for removing this project',
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text('Remove'),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
        ),
      ],
    );
  }
}
