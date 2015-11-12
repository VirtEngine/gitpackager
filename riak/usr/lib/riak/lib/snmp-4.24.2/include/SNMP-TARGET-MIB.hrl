%%% This file was automatically generated by snmpc_mib_to_hrl version 4.24.2
%%% Date: 02-Apr-2015::18:13:54
-ifndef('SNMP-TARGET-MIB').
-define('SNMP-TARGET-MIB', true).

%% Oids

-define(snmpTargetMIB, [1,3,6,1,6,3,12]).

-define(snmpTargetObjects, [1,3,6,1,6,3,12,1]).
-define(snmpTargetSpinLock, [1,3,6,1,6,3,12,1,1]).
-define(snmpTargetSpinLock_instance, [1,3,6,1,6,3,12,1,1,0]).

-define(snmpTargetAddrTable, [1,3,6,1,6,3,12,1,2]).

-define(snmpTargetAddrEntry, [1,3,6,1,6,3,12,1,2,1]).
-define(snmpTargetAddrName, 1).
-define(snmpTargetAddrTDomain, 2).
-define(snmpTargetAddrTAddress, 3).
-define(snmpTargetAddrTimeout, 4).
-define(snmpTargetAddrRetryCount, 5).
-define(snmpTargetAddrTagList, 6).
-define(snmpTargetAddrParams, 7).
-define(snmpTargetAddrStorageType, 8).
-define(snmpTargetAddrRowStatus, 9).

-define(snmpTargetParamsTable, [1,3,6,1,6,3,12,1,3]).

-define(snmpTargetParamsEntry, [1,3,6,1,6,3,12,1,3,1]).
-define(snmpTargetParamsName, 1).
-define(snmpTargetParamsMPModel, 2).
-define(snmpTargetParamsSecurityModel, 3).
-define(snmpTargetParamsSecurityName, 4).
-define(snmpTargetParamsSecurityLevel, 5).
-define(snmpTargetParamsStorageType, 6).
-define(snmpTargetParamsRowStatus, 7).
-define(snmpUnavailableContexts, [1,3,6,1,6,3,12,1,4]).
-define(snmpUnavailableContexts_instance, [1,3,6,1,6,3,12,1,4,0]).
-define(snmpUnknownContexts, [1,3,6,1,6,3,12,1,5]).
-define(snmpUnknownContexts_instance, [1,3,6,1,6,3,12,1,5,0]).

-define(snmpTargetConformance, [1,3,6,1,6,3,12,3]).

-define(snmpTargetCompliances, [1,3,6,1,6,3,12,3,1]).

-define(snmpTargetGroups, [1,3,6,1,6,3,12,3,2]).

-define(snmpTargetBasicGroup, [1,3,6,1,6,3,12,3,2,1]).

-define(snmpTargetResponseGroup, [1,3,6,1,6,3,12,3,2,2]).

-define(snmpTargetCommandResponderGroup, [1,3,6,1,6,3,12,3,2,3]).


%% Range values
-define(low_snmpTargetSpinLock, 0).
-define(high_snmpTargetSpinLock, 2147483647).
-define(low_snmpTargetAddrName, 1).
-define(high_snmpTargetAddrName, 32).
-define(low_snmpTargetAddrTAddress, 1).
-define(high_snmpTargetAddrTAddress, 255).
-define(low_snmpTargetAddrTimeout, 0).
-define(high_snmpTargetAddrTimeout, 2147483647).
-define(low_snmpTargetAddrRetryCount, 0).
-define(high_snmpTargetAddrRetryCount, 255).
-define(low_snmpTargetAddrTagList, 0).
-define(high_snmpTargetAddrTagList, 255).
-define(low_snmpTargetAddrParams, 1).
-define(high_snmpTargetAddrParams, 32).
-define(low_snmpTargetParamsName, 1).
-define(high_snmpTargetParamsName, 32).
-define(low_snmpTargetParamsMPModel, 0).
-define(high_snmpTargetParamsMPModel, 2147483647).
-define(low_snmpTargetParamsSecurityModel, 1).
-define(high_snmpTargetParamsSecurityModel, 2147483647).
-define(low_snmpTargetParamsSecurityName, 0).
-define(high_snmpTargetParamsSecurityName, 255).
-define(low_snmpUnavailableContexts, 0).
-define(high_snmpUnavailableContexts, 4294967295).
-define(low_snmpUnknownContexts, 0).
-define(high_snmpUnknownContexts, 4294967295).


%% Enum definitions from snmpTargetAddrStorageType
-define(snmpTargetAddrStorageType_readOnly, 5).
-define(snmpTargetAddrStorageType_permanent, 4).
-define(snmpTargetAddrStorageType_nonVolatile, 3).
-define(snmpTargetAddrStorageType_volatile, 2).
-define(snmpTargetAddrStorageType_other, 1).

%% Enum definitions from snmpTargetAddrRowStatus
-define(snmpTargetAddrRowStatus_destroy, 6).
-define(snmpTargetAddrRowStatus_createAndWait, 5).
-define(snmpTargetAddrRowStatus_createAndGo, 4).
-define(snmpTargetAddrRowStatus_notReady, 3).
-define(snmpTargetAddrRowStatus_notInService, 2).
-define(snmpTargetAddrRowStatus_active, 1).

%% Enum definitions from snmpTargetParamsSecurityLevel
-define(snmpTargetParamsSecurityLevel_authPriv, 3).
-define(snmpTargetParamsSecurityLevel_authNoPriv, 2).
-define(snmpTargetParamsSecurityLevel_noAuthNoPriv, 1).

%% Enum definitions from snmpTargetParamsStorageType
-define(snmpTargetParamsStorageType_readOnly, 5).
-define(snmpTargetParamsStorageType_permanent, 4).
-define(snmpTargetParamsStorageType_nonVolatile, 3).
-define(snmpTargetParamsStorageType_volatile, 2).
-define(snmpTargetParamsStorageType_other, 1).

%% Enum definitions from snmpTargetParamsRowStatus
-define(snmpTargetParamsRowStatus_destroy, 6).
-define(snmpTargetParamsRowStatus_createAndWait, 5).
-define(snmpTargetParamsRowStatus_createAndGo, 4).
-define(snmpTargetParamsRowStatus_notReady, 3).
-define(snmpTargetParamsRowStatus_notInService, 2).
-define(snmpTargetParamsRowStatus_active, 1).

%% Default values
-define(default_snmpTargetSpinLock, 0).
-define(default_snmpTargetAddrTimeout, 1500).
-define(default_snmpTargetAddrRetryCount, 3).
-define(default_snmpTargetAddrTagList, []).
-define(default_snmpTargetAddrStorageType, 3).
-define(default_snmpTargetParamsStorageType, 3).
-define(default_snmpUnavailableContexts, 0).
-define(default_snmpUnknownContexts, 0).

-endif.
