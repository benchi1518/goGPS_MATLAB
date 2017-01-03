%   CLASS Constellation Collector
% =========================================================================
%
% DESCRIPTION
%   Class to collect and store active Satellite System to be used in the
%   computations
%
%----------------------------------------------------------------------------------------------
%                           goGPS v0.5.9
% Copyright (C) 2009-2017 Mirko Reguzzoni, Eugenio Realini
% Written by:       Gatti Andrea
% Contributors:     Gatti Andrea, ...
%----------------------------------------------------------------------------------------------
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%----------------------------------------------------------------------------------------------
classdef Constellation_Collector < handle
    properties (Constant)
        N_SYS_TOT = 6; % max number of available satellite systems
        SYS_NAMES = {'GPS', 'GLO', 'GAL', 'BDS', 'QZS', 'SBS'};

    end
    
    properties (SetAccess = private, GetAccess = public)
        list       % struct of objects (to keep the name of the active constellations)
        sys_name   % rray of active constellations names (as in the list structure)
        num_id     % array of active constellations numeric id
        char_id    % array of active constellations char id
        n_sys      % number of active constellations
        n_sat      % uint8 array of satellite used per active constellation
        n_sat_tot  % uint8 total teoretical number of satellite available for processing
        enabled    % logical array of satellite actually active order: GPS GLO GAL BDS QZS SBS
        
        index      % incremental index of the active satellite system
        prn        % relative id number in the satellite system        
        system     % char id of the constellation per satellite
    end
            
    methods
        function obj = Constellation_Collector(GPS_flag, GLO_flag, GAL_flag, BDS_flag, QZS_flag, SBS_flag)
            % SYNTAX:
            %   cc = Constellation_Collector(GPS_flag, GLO_flag, GAL_flag, BDS_flag, QZS_flag, SBS_flag);
            %   cc = Constellation_Collector([GPS_flag, GLO_flag, GAL_flag, BDS_flag, QZS_flag, SBS_flag]);
            %
            % INPUT:
            %   single logical array whose elements are:
            %   GPS_flag = boolean flag for enabling/disabling GPS usage
            %   GLO_flag = boolean flag for enabling/disabling GLONASS usage
            %   GAL_flag = boolean flag for enabling/disabling Galileo usage
            %   BDS_flag = boolean flag for enabling/disabling BeiDou usage
            %   QZS_flag = boolean flag for enabling/disabling QZSS usage
            %   SBS_flag = boolean flag for enabling/disabling SBAS usage (for ranging)
            %
            % OUTPUT:
            %   object handler
            %
            % DESCRIPTION:
            %   Multi-constellation set-up.
            switch nargin
                case 1,  enabled_ss = GPS_flag;
                case 5,  enabled_ss = logical([GPS_flag, GLO_flag, GAL_flag, BDS_flag, QZS_flag, 0]);
                case 6,  enabled_ss = logical([GPS_flag, GLO_flag, GAL_flag, BDS_flag, QZS_flag, SBS_flag]);
                otherwise, error(['Initialization of Constellation_Collector failed: ' 10 '   invalid number of parameters in the constructor call']);
            end
            
            % check the size of the array enabled
            if (numel(enabled_ss) < obj.N_SYS_TOT)
                tmp = false(obj.N_SYS_TOT, 1);
                tmp(1:numel(enabled_ss)) = enabled_ss;
                enabled_ss = tmp;
                clear tmp;
            else
                enabled_ss = enabled_ss(1:obj.N_SYS_TOT);
            end
            
            obj.enabled = enabled_ss;
            obj.prn = [];     % relative id number in the satellite system
            obj.system = '';  % char id of the constellation per satellite
            
            obj.n_sat_tot = 0; % counter for number of satellites
            
            if enabled_ss(1) % GPS is active
                obj.list.GPS = GPS_SS(obj.n_sat_tot);
                obj.num_id = [obj.num_id 1];
                obj.char_id = [obj.char_id obj.list.GPS.char_id];
                obj.system = [obj.system char(ones(1, obj.list.GPS.n_sat) * obj.list.GPS.char_id)];
                obj.prn = [obj.prn; obj.list.GPS.prn];
                obj.n_sat = [obj.n_sat obj.list.GPS.n_sat];
                obj.n_sat_tot = obj.n_sat_tot + obj.list.GPS.n_sat;
            end
            if enabled_ss(2) % GLONASS is active
                obj.list.GLO = GLONASS_SS(obj.n_sat_tot);
                obj.num_id = [obj.num_id 2];
                obj.char_id = [obj.char_id obj.list.GLO.char_id];
                obj.system = [obj.system char(ones(1, obj.list.GLO.n_sat) * obj.list.GLO.char_id)];
                obj.prn = [obj.prn; obj.list.GLO.prn];
                obj.n_sat = [obj.n_sat obj.list.GLO.n_sat];
                obj.n_sat_tot = obj.n_sat_tot + obj.list.GLO.n_sat;
            end
            if enabled_ss(3) % Galileo is active
                obj.list.GAL = Galileo_SS(obj.n_sat_tot);
                obj.num_id = [obj.num_id 3];
                obj.char_id = [obj.char_id obj.list.GAL.char_id];
                obj.system = [obj.system char(ones(1, obj.list.GAL.n_sat) * obj.list.GAL.char_id)];
                obj.prn = [obj.prn; obj.list.GAL.prn];
                obj.n_sat = [obj.n_sat obj.list.GAL.n_sat];
                obj.n_sat_tot = obj.n_sat_tot + obj.list.GAL.n_sat;
            end
            if enabled_ss(4) % BeiDou is active
                obj.list.BDS = BeiDou_SS(obj.n_sat_tot);
                obj.num_id = [obj.num_id 4];
                obj.char_id = [obj.char_id obj.list.BDS.char_id];
                obj.system = [obj.system char(ones(1, obj.list.BDS.n_sat) * obj.list.BDS.char_id)];
                obj.prn = [obj.prn; obj.list.BDS.prn];
                obj.n_sat = [obj.n_sat obj.list.BDS.n_sat];
                obj.n_sat_tot = obj.n_sat_tot + obj.list.BDS.n_sat;
            end
            if enabled_ss(5) % QZSS is active
                obj.list.QZS = QZSS_SS(obj.n_sat_tot);
                obj.num_id = [obj.num_id 5];
                obj.char_id = [obj.char_id obj.list.QZS.char_id];
                obj.system = [obj.system char(ones(1, obj.list.QZS.n_sat) * obj.list.QZS.char_id)];
                obj.prn = [obj.prn; obj.list.QZS.prn];
                obj.n_sat = [obj.n_sat obj.list.QZS.n_sat];
                obj.n_sat_tot = obj.n_sat_tot + obj.list.QZS.n_sat;
            end
            if enabled_ss(6) % SBAS is active (not yet implemented) 
                obj.list.SBAS.n_sat = 0;    % (not yet implemented)
            end        
            
            obj.index = (1 : obj.n_sat_tot)';   % incremental index of the active satellite system
            obj.n_sys = numel(obj.list);
            obj.sys_name = obj.SYS_NAMES(obj.num_id);
        end                
    end
end