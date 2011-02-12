if Object.const_defined?(:Encoding)
  Encoding.default_external = 'EUC-JP'
end

require 'bitclust/requesthandler'
require 'bitclust/screen'
require 'bitclust/server'
require 'bitclust/searcher'
require 'bitclust/methoddatabase'
require 'bitclust/functiondatabase'
require 'bitclust/rrdparser'
require 'bitclust/exception'
