class BlocksController < ApplicationController
 
load_and_authorize_resource

   before_action :set_block, only: [:show, :edit, :update, :destroy]

  # GET /blocks
  # GET /blocks.json
  def index
    if !current_user || current_user.role == 'admin'
      @blocks = Block.all
    else
      @blocks = Block.all.where("id IN (SELECT blocks.id FROM blocks, blocks_courses, courses WHERE blocks.id = blocks_courses.block_id AND blocks_courses.course_id = courses.id AND courses.id = " + current_user.course_id.to_s + ")")
    end
  end

  # GET /blocks/new
  def new
    @block = Block.new
  end

  # POST /blocks
  # POST /blocks.json
  def create
    @block = Block.new(block_params)

    respond_to do |format|
      if @block.save
        format.html { redirect_to @block, notice: 'Block wurde erfolgreich erstellt.' }
        format.json { render :show, status: :created, location: @block }
      else
        format.html { render :new }
        format.json { render json: @block.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /blocks/1
  # PATCH/PUT /blocks/1.json
  def update
    respond_to do |format|
      if @block.update(block_params)
        format.html { redirect_to @block, notice: 'Block wurde erfolgreich geändert.' }
        format.json { render :show, status: :ok, location: @block }
      else
        format.html { render :edit }
        format.json { render json: @block.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blocks/1
  # DELETE /blocks/1.json
  def destroy
    @block.destroy
    respond_to do |format|
      format.html { redirect_to blocks_url, notice: 'Block wurde erfolgreich gelöscht.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_block
      @block = Block.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def block_params
      params.require(:block).permit(:name, :credits_min, :event_ids => [])
    end
end
