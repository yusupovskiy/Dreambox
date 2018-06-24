class Companies::FieldTemplatesController < ApplicationController
  
  def create
    new_field_template = FieldTemplate.new(params.require(:field_template).permit(:name, :field_type, :block_id))

    respond_to do |format|
      if new_field_template.save
        format.html { redirect_to request.referer, notice: "Поле <i>#{new_field_template.name}</i> добавлен" }
        format.json { render :show, status: :created, location: new_field_template }
      else
        format.html { render :new }
        format.json { render json: new_field_template.errors, status: :unprocessable_entity }
      end
    end

  end

end
