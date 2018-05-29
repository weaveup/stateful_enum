# frozen_string_literal: true

require 'rails/generators/named_base'

module StatefulEnum
  module Generators
    class GraphGenerator < ::Rails::Generators::NamedBase
      desc 'Draws a state machine diagram as a PNG file'
      def draw
        require 'ruby-graphviz'
        StatefulEnum::Machine.prepend StatefulEnum::Graph
        class_name.constantize
      end
    end
  end

  module Graph
    def initialize(model, column, states, prefix, suffix, &block)
      super
      GraphDrawer.new model, column, states, @prefix, @suffix, &block
    end

    class GraphDrawer
      def initialize(model, column, states, prefix, suffix, &block)
        @states, @prefix, @suffix = states, prefix, suffix
        @g = ::GraphViz.new 'G', rankdir: 'TB'

        states.each do |state|
          @g.add_node state.to_s, label: state.to_s, width: '1', height: '1', shape: 'ellipse'
        end
        if (default_value = model.columns_hash[column.to_s].default)
          default_label = model.defined_enums[column.to_s].key default_value.to_i  # SQLite returns the default value in String
          @g.add_edge @g.add_node('start state', shape: 'point'), @g.get_node(default_label)
        end

        instance_eval(&block)

        (@g.each_edge.map(&:node_two).uniq - @g.each_edge.map(&:node_one).uniq).each do |final|
          @g.get_node(final) {|n| n['shape'] = 'doublecircle' }
        end

        @g.output png: File.join((ENV['DEST_DIR'] || Dir.pwd), "#{model.name}.png")
      end

      def event(name, &block)
        EventDrawer.new @g, @states, @prefix, @suffix, name, &block
      end
    end

    class EventDrawer < ::StatefulEnum::Machine::Event
      def initialize(g, states, prefix, suffix, name, &block)
        @g, @states, @prefix, @suffix, @name = g, states, prefix, suffix, name
        @before, @after = [], []

        instance_eval(&block) if block
      end

      def transition(transitions, options = {})
        if options.blank?
          transitions.delete :if
          transitions.delete :unless
        end

        transitions.each_pair do |from, to|
          Array(from).each do |f|
            @g.add_edge f.to_s, to.to_s, label: "#{@prefix}#{@name}#{@suffix}"
          end
        end
      end
    end
  end
end
