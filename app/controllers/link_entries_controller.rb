class LinkEntriesController < ApplicationController
  def index
    @link_entries = LinkEntry.all
  end

  def new
    @link_entry = LinkEntry.new
  end

  def create
    @link_entry = LinkEntry.new(link_entry_params)

    if @link_entry.save
      redirect_to :link_entries
    else
      render :new, status: :unprocessable_entity
    end
  end

  def perform_redirect
    entry = LinkEntry.find_by!(short_id: params[:short_id])

    redirect_to entry.external_url, allow_other_host: true
  end

  def destroy
    e = LinkEntry.find(params[:id])
    e.destroy
    redirect_to :link_entries
  end

private
  def link_entry_params
    params.require(:link_entry).permit(:external_url)
  end

end
