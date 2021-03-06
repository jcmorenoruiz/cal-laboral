class RequestsController < ApplicationController
  
  before_action :signed_in_user
  before_action :chief_user, only: [:edit, :update]
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  #before_action :correct_user, only: [:create, :edit, :update , :destroy]


  def new
  	@emp=Employee.find(params[:id])
  	@request=Request.new

    if admin_user? && params[:id]!=current_user.id
      @request_types=Employee.find(params[:id]).department.request_types.where(:status => true,:tipo => true) 
    else
      @request_types=current_user.department.request_types.where(:status => true,:tipo => true)
    end

       
  end

  def create

		@emp = Employee.find(params[:request][:employee_id])

    #distingir por perfiles

    if admin_user? && @emp.id!=current_user.id
      @request_types=Employee.find(@emp.id).department.request_types.where(:status => true,:tipo => true) 
    else
      @request_types=current_user.department.request_types.where(:status => true,:tipo => true)
    end
    

    @request= @emp.requests.build(requests_params)
    if admin_user? 
      @request.status=2  
    end

    if @request.save
      if admin_user?
        flash[:success]= 'Asignación de Ausencia generada correctamente. Se ha enviado un email a los empleados indicando la Ausencia.'
        redirect_to employees_path
      else
        flash[:success]= 'Solicitud generada correctamente. Se le notificará el resultado de la auditoría cuando sea efectuada.'
        redirect_to employee_path(@emp)
      end
        
    else
        render "new" 
    end

  end

  def edit
     
  end

  def update

      if @request.update_attributes(:status => params[:request][:status],:motivo_rev => params[:request][:motivo_rev])
          flash[:success]="Solicitud procesada correctamente. Se ha enviado un email con el aviso correspondiente."
          redirect_to employee_path(current_user.id)
      else
          render "edit"
      end
  end

  def show 
   
  end
  
  

  def destroy   
    @emp = Employee.find(@request.employee_id)
    @request.destroy
    flash[:success]='Solicitud anulada correctamente'
    redirect_to employee_path(@emp) 
  end

  def stats
    @calendars=Calendar.select('distinct anio').where(department_id: current_emp.departments)

    if !params[:calendar].blank?
      @year=params[:calendar]
    else
      @year=Date.current.year
    end


    if !params[:department].blank?
     @requests_types=RequestType.where(:id => DepartmentsRequestType.select('request_type_id').where(:department_id => params[:department]))
    else
     @requests_types=RequestType.where(:enterprise_id => current_emp)
    end
    
    @dptos=Department.where(:enterprise_id =>current_emp)
  end


  def calendar
    @dptos=Department.where(:enterprise_id =>current_emp)
    @ndias=['D','L','M','X','J','V','S']
    @requests_types=RequestType.where(:enterprise_id => current_emp)
    
    @date=Date.today
    
    if params[:date].present?
      if !params[:date][:month].blank? || !params[:date][:year].blank?
        @date=Date.new(params[:date][:year].to_i,params[:date][:month].to_i,1)  
      end
    end 
    # generate header calendar table
    @iniciomes=Date.new(@date.year,@date.month,1)
    @finmes=Date.new(@date.year,@date.month,@date.end_of_month.day)
    @nombredias=(@iniciomes..@finmes).map{ |date| @ndias[date.wday] }
    @diasmes=(1..@date.end_of_month.day).to_a
    @fechas=(@iniciomes..@finmes).map{ |date| date }


   
    params[:starts_with].present? ? nombre=params[:starts_with] : nombre=""

    if params[:department].present?
        @employees=Employee.where(:department_id => params[:department]).where('upper(nombre) like ?',"%#{nombre.upcase}%")
    else
        @employees=Employee.where(:department_id => current_emp.departments).where('upper(nombre) like ?',"%#{nombre.upcase}%")
    end
    



  end


  protected

  def weekdays_in_date_range(range)
    # You could modify the select block to also check for holidays
    range.select { |d| (1..5).include?(d.wday) }.size
  end

  private

   def set_request
      @request = Request.find(params[:id])
    end

  	def requests_params
  		 params.require(:request).permit(:desde, :hasta, :request_type_id, :motivo)
  	end

end
