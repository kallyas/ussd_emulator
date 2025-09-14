import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/template_provider.dart';
import '../providers/ussd_provider.dart';
import '../models/session_template.dart';
import '../utils/design_system.dart';
import '../l10n/generated/app_localizations.dart';
import 'template_builder_screen.dart';
import 'template_execution_screen.dart';

class TemplateLibraryScreen extends StatefulWidget {
  const TemplateLibraryScreen({super.key});

  @override
  State<TemplateLibraryScreen> createState() => _TemplateLibraryScreenState();
}

class _TemplateLibraryScreenState extends State<TemplateLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final templateProvider = context.read<TemplateProvider>();
      final ussdProvider = context.read<UssdProvider>();
      if (!templateProvider.isInitialized) {
        templateProvider.init(ussdProvider);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Consumer<TemplateProvider>(
        builder: (context, templateProvider, child) {
          if (!templateProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildHeader(context, templateProvider),
              _buildSearchAndFilters(context, templateProvider),
              Expanded(
                child: _buildTemplateList(context, templateProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToTemplateBuilder(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.createTemplate),
        tooltip: l10n.createNewTemplate,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TemplateProvider templateProvider) {
    final l10n = AppLocalizations.of(context);
    final stats = templateProvider.getStatistics();

    return Container(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(UssdDesignSystem.radiusM),
          bottomRight: Radius.circular(UssdDesignSystem.radiusM),
        ),
        boxShadow: UssdDesignSystem.getShadow(2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
                ),
                child: Icon(
                  Icons.folder_special_rounded,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 32,
                ),
              ),
              const SizedBox(width: UssdDesignSystem.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.templateLibrary,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.manageUssdTemplates,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UssdDesignSystem.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.totalTemplates,
                  stats['totalTemplates'].toString(),
                  Icons.folder_rounded,
                ),
              ),
              const SizedBox(width: UssdDesignSystem.spacingM),
              Expanded(
                child: _buildStatCard(
                  context,
                  l10n.categories,
                  stats['categories'].toString(),
                  Icons.category_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusS),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: UssdDesignSystem.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, TemplateProvider templateProvider) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchTemplates,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: templateProvider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        templateProvider.searchTemplates('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
              ),
            ),
            onChanged: templateProvider.searchTemplates,
          ),
          if (templateProvider.categories.isNotEmpty) ...[
            const SizedBox(height: UssdDesignSystem.spacingM),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip(
                    context,
                    l10n.allCategories,
                    null,
                    templateProvider.selectedCategory == null,
                    () => templateProvider.filterByCategory(null),
                  ),
                  ...templateProvider.categories.map(
                    (category) => _buildCategoryChip(
                      context,
                      category,
                      category,
                      templateProvider.selectedCategory == category,
                      () => templateProvider.filterByCategory(category),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String? value,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: UssdDesignSystem.spacingS),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildTemplateList(BuildContext context, TemplateProvider templateProvider) {
    final l10n = AppLocalizations.of(context);
    final templates = templateProvider.templates;

    if (templateProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (templateProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            Text(
              templateProvider.error!,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            ElevatedButton(
              onPressed: () => templateProvider.clearError(),
              child: Text(l10n.dismiss),
            ),
          ],
        ),
      );
    }

    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: UssdDesignSystem.spacingM),
            Text(
              templateProvider.searchQuery.isNotEmpty || templateProvider.selectedCategory != null
                  ? l10n.noTemplatesFound
                  : l10n.noTemplatesYet,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UssdDesignSystem.spacingS),
            Text(
              templateProvider.searchQuery.isNotEmpty || templateProvider.selectedCategory != null
                  ? l10n.tryDifferentSearch
                  : l10n.createFirstTemplate,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (templateProvider.searchQuery.isEmpty && templateProvider.selectedCategory == null)
              Padding(
                padding: const EdgeInsets.only(top: UssdDesignSystem.spacingL),
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToTemplateBuilder(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createTemplate),
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final template = templates[index];
        return _buildTemplateCard(context, template, templateProvider)
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 50))
            .slideX(begin: 0.1, end: 0.0);
      },
    );
  }

  Widget _buildTemplateCard(
    BuildContext context,
    SessionTemplate template,
    TemplateProvider templateProvider,
  ) {
    final l10n = AppLocalizations.of(context);
    final isValid = templateProvider.validateTemplate(template);

    return Card(
      margin: const EdgeInsets.only(bottom: UssdDesignSystem.spacingM),
      child: InkWell(
        borderRadius: BorderRadius.circular(UssdDesignSystem.radiusM),
        onTap: () => _showTemplateActions(context, template, templateProvider),
        child: Padding(
          padding: const EdgeInsets.all(UssdDesignSystem.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isValid 
                          ? Colors.green 
                          : Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: UssdDesignSystem.spacingS),
                  Expanded(
                    child: Text(
                      template.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (template.category != null)
                    Chip(
                      label: Text(
                        template.category!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                ],
              ),
              const SizedBox(height: UssdDesignSystem.spacingS),
              Text(
                template.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: UssdDesignSystem.spacingM),
              Row(
                children: [
                  Icon(
                    Icons.phone_in_talk_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: UssdDesignSystem.spacingXS),
                  Text(
                    template.serviceCode,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: UssdDesignSystem.spacingM),
                  Icon(
                    Icons.list_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: UssdDesignSystem.spacingXS),
                  Text(
                    l10n.stepCount(template.steps.length),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: isValid 
                        ? () => _executeTemplate(context, template, templateProvider)
                        : null,
                    tooltip: l10n.executeTemplate,
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showTemplateActions(context, template, templateProvider),
                    tooltip: l10n.moreActions,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTemplateBuilder(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TemplateBuilderScreen(),
      ),
    );
  }

  void _executeTemplate(
    BuildContext context,
    SessionTemplate template,
    TemplateProvider templateProvider,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateExecutionScreen(template: template),
      ),
    );
  }

  void _showTemplateActions(
    BuildContext context,
    SessionTemplate template,
    TemplateProvider templateProvider,
  ) {
    final l10n = AppLocalizations.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(UssdDesignSystem.radiusL),
        ),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(UssdDesignSystem.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: UssdDesignSystem.spacingL),
            Text(
              template.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: UssdDesignSystem.spacingL),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editTemplate),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TemplateBuilderScreen(template: template),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: Text(l10n.duplicateTemplate),
              onTap: () async {
                Navigator.pop(context);
                await templateProvider.duplicateTemplate(template.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.exportTemplate),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement export functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              title: Text(
                l10n.deleteTemplate,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmation(context, template.name);
                if (confirmed) {
                  await templateProvider.deleteTemplate(template.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String templateName) async {
    final l10n = AppLocalizations.of(context);
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTemplate),
        content: Text(l10n.confirmDeleteTemplate(templateName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    ) ?? false;
  }
}