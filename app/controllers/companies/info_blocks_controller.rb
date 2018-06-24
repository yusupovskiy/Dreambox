class Companies::InfoBlocksController < ApplicationController

  def create
    new_block = InfoBlock.new(params.require(:info_block).permit(:name, :model_object))
    new_block.company_id = @current_company.id

    respond_to do |format|
      if new_block.save
        format.html { redirect_to request.referer, notice: "Блок <i>#{new_block.name}</i> добавлен" }
        format.json { render :show, status: :created, location: new_block }
      else
        format.html { render :new }
        format.json { render json: new_block.errors, status: :unprocessable_entity }
      end
    end

  end

end
