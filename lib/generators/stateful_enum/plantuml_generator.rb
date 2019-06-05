# frozen_string_literal: true

require 'rails/generators/named_base'

module StatefulEnum
  module Generators
    class PlantumlGenerator < ::Rails::Generators::NamedBase
      desc 'Draws a PlantUML state machine diagram'
      def plantuml
        StatefulEnum::Machine.prepend StatefulEnum::PlantUML
        class_name.constantize
      end
    end
  end

  module PlantUML
    def initialize(model, column, states, prefix, suffix, &block)
      super
      UmlWriter.new model, column, states, @prefix, @suffix, &block
    end

    class UmlWriter
      def initialize(model, column, states, prefix, suffix, &block)
        @states, @prefix, @suffix = states, prefix, suffix
        @items = []

        if (default_value = model.columns_hash[column.to_s].default)
          default_label = model.defined_enums[column.to_s].key default_value.to_i  # SQLite returns the default value in String
        end

        instance_eval(&block)

        lines = default_label ? ["[*] --> #{default_label}"] : []
        lines.concat @items.map {|item| "#{item.from} --> #{item.to} :#{item.label}" }
        (@items.map(&:to).uniq - @items.map(&:from).uniq).each do |final|
          lines.push "#{final} --> [*]"
        end

        File.write(File.join((ENV['DEST_DIR'] || Dir.pwd), "#{model.name}.puml"), lines.join("\n") << "\n")
      end

      def event(name, &block)
        EventStore.new @items, @states, @prefix, @suffix, name, &block
      end
    end

    class EventStore < ::StatefulEnum::Machine::Event
      def initialize(items, states, prefix, suffix, name, &block)
        @items, @states, @prefix, @suffix, @name, @before, @after = items, states, prefix, suffix, name, [], []

        instance_eval(&block) if block
      end

      def transition(transitions, options = {})
        if options.blank?
          transitions.delete :if
          transitions.delete :unless
        end

        transitions.each_pair do |from, to|
          Array(from).each do |f|
            @items.push Item.new(f, to, "#{@prefix}#{@name}#{@suffix}")
          end
        end
      end
    end

    Item = Struct.new(:from, :to, :label)
  end
end
