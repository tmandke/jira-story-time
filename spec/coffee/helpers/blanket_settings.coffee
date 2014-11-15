# blanket.options 'filter', ['extension/js/models/', 'extension/js/views/', 'extension/js/utils/']
blanket.options 'branchTracking', true
blanket.options 'reporter', (coverage_results, opts) ->
  window.blanketResults = blanket.defaultReporter(coverage_results, opts)
