module RubocopDemo
  class FileWithOffense
    delegate :new_file, :delete_file,
      :old_path, :new_path
  end
end
